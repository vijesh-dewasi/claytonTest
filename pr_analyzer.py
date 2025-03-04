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
# Get apex rules

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
        You are an **Apex Code Review AI**, specialized in reviewing Apex pull requests for best practices, governor limits, and security risks.

        **Objective:**
        - Identify potential issues in the provided Apex code.
        - Categorize findings as **Errors** or **Warnings** based on severity.
        - If no issues are found, explicitly state: `NO_ISSUES_DETECTED`.

        **Common Apex Issues to Detect:**
        {apex_rules}

        **Response Format:**
        ```
        [SEVERITY: High/Medium/Low]
        [ERROR/WARNING]
        [file_name.cls]
        Line [line_number]: [Issue Type] - [Description]
        Suggestion: [Possible Fix]
        ```

        **Pull Request Data:**
        {pr_data}

        **Instructions:**
        - Analyze each line of code carefully.
        - Group issues under **High**, **Medium**, and **Low** severity.
        - Clearly mention whether the issue is an **Error** or **Warning**.
        - Provide specific **line numbers** and **issue types**.
        - Offer **concise, actionable suggestions** (avoid generic responses).
        - If no issues are found, output: `NO_ISSUES_DETECTED`.
    """



    prompt = PromptTemplate(input_variables=["pr_data", "apex_rules"], template=prompt_template)

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
        has_errors = False  # Track if errors are detected

        if files_changed:
            for file in files_changed:
                pr_summary = summarize_code_changes(file['patch'], apex_rules)
                summary.append(f"- **{file['filename']}**: \n{pr_summary}")

                # Check if "ERROR" is found in the LLM response
                if "ERROR" in pr_summary:
                    has_errors = True  # Mark errors found

        # Append status for GitHub Actions check
        if has_errors:
            summary.append("\nLLM_STATUS: FAIL")
        else:
            summary.append("\nLLM_STATUS: PASS")
        return "\n".join(summary)

    else:
        print("No PRs found or error fetching PRs.")
        return "No PRs found or error fetching PRs.\nLLM_STATUS: FAIL"


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
    print(analysis_result)
    post_pr_comment(analysis_result)
