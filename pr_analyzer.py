import requests
from langchain.prompts import PromptTemplate
from langchain_mistralai import ChatMistralAI
from dotenv import load_dotenv, find_dotenv
import os

# Load environment variables
load_dotenv(find_dotenv())

GITHUB_REPO = os.getenv('GITHUB_REPO')
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
PR_NUMBER = os.getenv("GITHUB_PR_NUMBER")


# ================================================================================================================================================

# get details of single pr on the basis of pr number
def get_pull_request():
    url = f"https://api.github.com/repos/{GITHUB_REPO}/pulls/{PR_NUMBER}"
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code}")
        return None

# ================================================================================================================================================

# Function to get files changed in a specific PR
def get_pr_files():
    url = f"https://api.github.com/repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/files"
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code}")
        return None


# ================================================================================================================================================

# Function to extract PR details
def get_pr_details(pr):
    pr_data = {
        "title": pr.get("title"),
        "description": pr.get("body"),
        "author": pr.get("user", {}).get("login"),
        "url": pr.get("html_url"),
        "number": pr.get("number")
    }
    return pr_data


# ================================================================================================================================================
# Get rules

def getApexRules():
    """get rules from the apex rules file"""
    with open("apex_rules.txt", "r", encoding="utf-8") as f:
        all_rules = f.readlines()
        return "".join(rule for rule in all_rules)

# ================================================================================================================================================

# Summarizing code changes using LangChain
def summarize_code_changes(code_diff, apex_rules):
    # Create a prompt template for code summarization
    # Define the prompt template
    prompt_template = """
        You are an **Apex Code Review AI** specialized in analyzing pull requests for best practices, governor limits, and security risks.

        **Objective:**
        - Review the entire code thoroughly before making judgments.
        - Identify potential issues and suggest improvements.
        - If no issues are found, explicitly state that the code follows best practices.

        **Common Apex Issues to Detect:**
        {apex_rules}

        **Response Format:**
        ```
        ERRORS: 
        [file_name.cls]
        Line [line_number]: [Issue Type] - [Description]
        Suggestion: [Possible Fix]

        WARNING: 
        [file_name.cls]
        Line [line_number]: [Issue Type] - [Description]
        Suggestion: [Possible Fix]
        ```

        **Pull Request Data:**
        {pr_data}

        **Instructions:**
        - Carefully examine each line of code for the issues listed above.
        - Provide a detailed analysis, specifying the line number and type of issue and please mention the severity of issue detected during your analysis.
        - Offer clear and actionable suggestions for improvement.
        - Ensure your response is structured and easy to understand and don't include any unecessory information on resonse, keep it short.
        - Also mention Error vs Warning which may be caused by the issue listed.
        - Categorised and group the feedback/(issues detected) based on their severity.
    """


    prompt = PromptTemplate(input_variables=["pr_data"], template=prompt_template)

    # Initialize Mistral Chat Model
    llm = ChatMistralAI(model="mistral-large-latest", temperature=0.7)

    # Create LLM Chain     
    chain = prompt | llm

    # Get summary of code changes
    summary = chain.invoke({"pr_data": code_diff, "apex_rules": apex_rules})
    return summary.content

# ================================================================================================================================================

# function to link everything for single pr

def analyze_pull_request():
    pr = get_pull_request()
    if pr:
        pr_details = get_pr_details(pr)
        summary = []
        summary.append(f"**PR Title:** {pr_details['title']}")
        summary.append(f"**Author:** {pr_details['author']}")
        summary.append(f"**PR URL:** {pr_details['url']}")
        summary.append(f"**PR Description:** {pr_details['description']}")
        summary.append("\n### Code Changes Summary:\n")
        
        # Fetch the files changed in this PR
        files_changed = get_pr_files()
        apex_rules = getApexRules()
        if files_changed:
            for file in files_changed:
                # print(f"File: {file['filename']}")
                # print(f"Status: {file['status']}")
                # print(f"Changes: {file['patch'][:500]}...")  # Limit the output for large diffs
                
                # Summarize the code changes using LangChain
                pr_summary = summarize_code_changes(file['patch'], apex_rules)
                summary.append(f"- **{file['filename']}**: \n{pr_summary}")
                print(f"Code Changes Summary: {pr_summary}")
                print("="*80)
        return "\n".join(summary)  # Return the formatted summary as a string
    else:
        print("No PRs found or error fetching PRs.")
        return "No PRs found or error fetching PRs."

# ================================================================================================================================================
# post comment on the pr

def post_pr_comment(comment):
    """Post analysis result as a PR comment"""
    url = f"https://api.github.com/repos/{GITHUB_REPO}/issues/{PR_NUMBER}/comments"
    headers = {"Authorization": f"token {GITHUB_TOKEN}", "Accept": "application/vnd.github.v3+json"}
    payload = {"body": comment}
    response = requests.post(url, headers=headers, json=payload)
    
    if response.status_code == 201:
        print("Comment posted successfully.")
    else:
        print(f"Failed to post comment: {response.status_code}, {response.text}")

# ================================================================================================================================================

# Run the PR analysis

if __name__ == "__main__":
    analysis_result = analyze_pull_request()
    post_pr_comment(analysis_result)
