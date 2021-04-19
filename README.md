# Github-PR-decoration-Action
This github action will use sonarscanner to analyse your Pull Request against a running Sonarqube instance (either a privately operated or Sonarcloud).  
When the analysis has finished, the report will be published on the "Checks" tab on the PR in Github.

Please see the /documentation/analysis/pr-decoration/ on your SonarQube instance on how to setup Sonarsqube to enable PR decoration.  
How to setup an app in Github, you can read on https://docs.github.com/en/developers/apps/creating-a-github-app.

To run the sonarscanner an decorate your pull requests, paste the code from the sonarqube-pr-decoration.yml file in the action, enter the values for **sonarProjectKey, sonarProjectName, dotnetBuildArguments** and **sonarHostName** and save it.

```yaml
on: 
  pull_request:
    branches:
      - develop
name: Dotnet build, Sonarscanner and PR decoration
jobs:
  sonarscanner-pr-decoration:
    runs-on: ubuntu-latest
    name: Dotnet build, Sonarscanner and PR decoration
    steps:
      - uses: actions/checkout@v2
      - uses: xablu/github-pr-decoration-action@main
        name: Dotnet build and SonarScanner for .NET 5 with pull request decoration support
        with:
          # The key of the SonarQube project
          sonarProjectKey: your sonarqube project key goes here
          # The name of the SonarQube project
          sonarProjectName:  "your sonarqube project name goes here"
          # The solution file or project name
          dotnetBuildArguments: Your project file or solution file including relative path goes here
          # The SonarQube server URL. For SonarCloud, skip this setting.
          sonarHostname:  the full url of your SonarQube server instance goes here
          # Pass github event pull_request head sha
          sonarBeginArguments: /d:sonar.scm.revision=${{ github.event.pull_request.head.sha }}
          # Enable or disable Sonarscan (true=enable, false=disable)
          sonarEnableScan: true
        env:
          SONAR_TOKEN: ${{ secrets.SONARQUBE_TOKEN }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
Please make sure you create 1 secret in your repository.  
The first one will store your SonarQube token, which you can setup in your SOnarQube account.  

## Setup script
Requirements:  
* git-lfs  
  
There is also a setup-script that can be used to easily setup both the action on Github as well as setup the project on Sonarqube.  
The scripts are in the folder setup-scripts. At the moment there is only a bash script.  
Run the script and enter the information that is required.