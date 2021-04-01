#!/bin/bash

# define variables and functions
srcdir="${HOME}/source"
wfdirectory="$srcdir/.github/workflows"
wffile="pr-decoration.yaml"
githubbaseurl="github.com"
uservars=("gitusername" "gitpass" "githubrepo" "sqtoken" "sqtestreport" "sqserver" "branch" "sqprojectname" "sqprojectkey" "sqbuildargs")
next="true"

### define functions ###
function write-yaml() {
    # create yaml workflow file
    echo "Writing wrokflow file"
    echo "on:" >> "$wfdirectory/$wffile"
    echo "  pull_request:" >> "$wfdirectory/$wffile"
    echo "    branches:" >> "$wfdirectory/$wffile"
    echo "      - $branch" >> "$wfdirectory/$wffile"
    echo "name: Scripted Sonarscanner and PR decoration" >> "$wfdirectory/$wffile"
    echo "jobs:" >> "$wfdirectory/$wffile"
    echo "  sonarscanner-pr-decoration:" >> "$wfdirectory/$wffile"
    echo "    runs-on: ubuntu-latest" >> "$wfdirectory/$wffile"
    echo "    name: Scripted Sonarscanner and PR decoration" >> "$wfdirectory/$wffile"
    echo "    steps:" >> "$wfdirectory/$wffile"
    echo "      - uses: actions/checkout@v2" >> "$wfdirectory/$wffile"
    echo "        name: Checkout" >> "$wfdirectory/$wffile"
    echo "        with:" >> "$wfdirectory/$wffile"
    echo "          fetch-depth: '0'" >> "$wfdirectory/$wffile"
    echo "      - run: git fetch origin $branch" >> "$wfdirectory/$wffile"
    echo "        name: Fetching $branch branch" >> "$wfdirectory/$wffile"
    echo "      - uses: highbyte/sonarscan-dotnet@2.0" >> "$wfdirectory/$wffile"
    echo "        name: SonarScanner for .NET 5 with pull request decoration support" >> "$wfdirectory/$wffile"
    echo "        with:" >> "$wfdirectory/$wffile"
    echo "          # The key of the SonarQube project" >> "$wfdirectory/$wffile"
    echo "          sonarProjectKey: $sqprojectkey" >> "$wfdirectory/$wffile"
    echo "          # The name of the SonarQube project" >> "$wfdirectory/$wffile"
    echo "          sonarProjectName:  \"$sqprojectname\"" >> "$wfdirectory/$wffile"
    echo "          dotnetBuildArguments: $sqbuildargs" >> "$wfdirectory/$wffile"
    echo "          dotnetDisableTests: '1'" >> "$wfdirectory/$wffile"
    echo "          # The SonarQube server URL. For SonarCloud, skip this setting." >> "$wfdirectory/$wffile"
    echo "          sonarHostname:  https://$sqserver" >> "$wfdirectory/$wffile"
    echo "          # Pass github event pull_request head sha" >> "$wfdirectory/$wffile"
    echo "          sonarBeginArguments: /d:sonar.scm.revision="\${{ github.event.pull_request.head.sha }}\ >> "$wfdirectory/$wffile"
    echo "        env:" >> "$wfdirectory/$wffile"
    echo "          SONAR_TOKEN: "\${{ secrets.SONARQUBE_TOKEN }} >> "$wfdirectory/$wffile"
    echo "          GITHUB_TOKEN: "\${{ secrets.GITHUB_TOKEN }} >> "$wfdirectory/$wffile"

}

function git-checkout() {
    git remote add origin "https://$githubbaseurl/$githubrepo.git"
    git config gc.auto 0
    git config --get-all "http.https://$githubbaseurl/$githubrepo.git.extraheader"
    git config --get-all http.proxy
    git config http.version HTTP/1.1
    git remote set-url origin "https://$gitusername:$gitpass@$githubbaseurl/$githubrepo.git" > /dev/null
    git fetch --force --tags --prune --progress --no-recurse-submodules origin
    newbranch_sha1=$(git rev-parse origin/$branch)
    git lfs fetch origin $newbranch_sha1
    git checkout --progress --force $branch
    git submodule sync --recursive
    git submodule update --init --force --recursive
}

function commit-workflow() {
    git add $1
    git commit -m "Added workflowfile"
    git push -u origin $branch
}

function user-input() {
    if [[ "$1" == "gitusername" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Please enter a Github user name: ' gitusername
            if [[ -z "$gitusername" ]]; then
                next="false"
                user-input gitusername second
            else
                next="true"
            fi
        else
            read -p 'Github Username cannot be empty. Please enter a Github username: ' gitusername
            if [[ -z "$gitusername" ]]; then
                next="false"
                user-input gitusername second
            else
                next="true"
            fi
        fi
    fi

    if [[ "$1" == "gitpass" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -sp 'Please enter the github password: ' gitpass
            next="true"
        fi
    fi

    if [[ "$1" == "githubrepo" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Please enter Github repo (githubusername/repository): ' githubrepo
            if [[ -z "$githubrepo" ]]; then
                next="false"
                user-input githubrepo second
            else
                next="true"
            fi
        else
            read -p 'Githubrepo cannot be empty: Please enter Githubrepo (githubusername/repository): ' githubrepo
            if [[ -z "$githubrepo" ]]; then
                next="false"
                user-input githubrepo second
            else
                next="true"
            fi
        fi
    fi

    if [[ "$1" == "sqtoken" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -sp 'Please enter the SonarQube token: ' sqtoken
            if [[ -z "$sqtoken" ]]; then
                next="false"
                user-input sqtoken second
            else
                next="true"
            fi
        else
            echo
            read -sp 'SonarQube token cannot be empty: Please enter a SonarQube token: ' sqtoken
            if [[ -z "$sqtoken" ]]; then
                next="false"
                user-input sqtoken second
            else
                next="true"
            fi
        fi
    fi

    if [[ "$1" == "sqtestreport" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Setup nunit test reports location for c# in Sonarqube? (Y/n) ' sqtestreport
            if [ -z "$sqtestreport" ]; then
                sqtestreport="y"
            fi
            next="true"
        fi
    fi

    if [[ "$1" == "sqserver" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Sonarqube server (default=codequality.xablu.com): ' sqserver
            if [ -z "$sqserver" ]; then
                sqserver="codequality.xablu.com"
            fi
            next="true"
        fi
    fi

    if [[ "$1" == "branch" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Please enter the github branch for merging PRs into: ' branch
            if [[ -z "$branch" ]]; then
                next="false"
                user-input branch second
            else
                next="true"
            fi
        else
            read -p 'The branch cannot be empty. Please enter the github branch for merging PRs into: ' branch
            if [[ -z "$branch" ]]; then
                next="false"
                user-input branch second
            else
                next="true"
            fi
        fi
    fi

    if [[ "$1" == "sqprojectname" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Please enter the project name on SonarQube: ' sqprojectname
            if [[ -z "$sqprojectname" ]]; then
                next="false"
                user-input sqprojectname second
            else
                next="true"
            fi
        else
            read -p 'The SonarQube project name cannot be empty. Please enter the SonarQube project name: ' sqprojectname
            if [[ -z "$sqprojectname" ]]; then
                next="false"
                user-input sqprojectname second
            else
                next="true"
            fi
        fi
    fi

    if [[ "$1" == "sqprojectkey" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Please enter the project key on SonarQube (The project key is cap-sensitive!!): ' sqprojectkey
            if [[ -z "$sqprojectkey" ]]; then
                next="false"
                user-input sqprojectkey second
            else
                next="true"
            fi
        else
            read -p 'The SonarQube project key cannot be empty. Please enter the SonarQube project key: ' sqprojectkey
            if [[ -z "$sqprojectkey" ]]; then
                next="false"
                user-input sqprojectkey second
            else
                next="true"
            fi
        fi
    fi

    if [[ "$1" == "sqbuildargs" ]]; then
        if [[ "$2" == "first" ]]; then
            echo
            read -p 'Please enter the relative path to the solution or csproj file (for example src/project.sln): ' sqbuildargs
            if [[ -z "$sqbuildargs" ]]; then
                next="false"
                user-input sqbuildargs second
            else
                next="true"
            fi
        else
            read -p 'The path to the solution cannot be empty. Please enter the relative path to the solution or csproj file (for example src/project.sln): ' sqbuildargs
            if [[ -z "$sqbuildargs" ]]; then
                next="false"
                user-input sqbuildargs second
            else
                next="true"
            fi
        fi
    fi
}

function pause(){
   read -p "$*"
}
### End define functions ###

# step 1 Get information from user and define variables

for uservar in ${uservars[@]}; do
    next="false"
    while [ "$next" = "false" ]
    do
        user-input $uservar first
    done
done

# Step 2 pull github repository
# check if source dir exists
if [ -d "$srcdir" ]; then
    echo "Source folder exists. Deleting"
    rm -rf "${HOME}/source"
    git init $srcdir
    cd $srcdir
    git-checkout
else
    cd $srcdir
    git-checkout
fi

# Step 3 Create workflow.yml file and commit.
if [ ! -f "$wfdirectory/$wffile" ]; then
    mkdir -p $wfdirectory
    write-yaml
    echo "Workflow file $wffile written to $wfdirectory"
    echo "Committing file."
    commit-workflow $wfdirectory/$wffile
else
    echo "Workflow file does exist. Deleting file."
    rm "$wfdirectory/$wffile"
    write-yaml
    echo "Committing file."
    commit-workflow $wfdirectory/$wffile
fi

# step 4 Setup project in SQ
# first add SonarQube testreport location
if [[ "$sqtestreport" == "y" || "$sqtestreport" == "" ]]; then
    if [[ "$sqserver" != "" && "$sqprojectkey" != "" ]]; then
        echo "Adding c# nunit testreport location."
        resulttestreport=$(curl --location -u $sqtoken: --request POST "https://$sqserver/api/settings/set?component=$sqprojectkey&key=sonar.cs.nunit.reportsPaths&values=**%2FTestResult.xml")
        if [ -z "$resulttestreport" ]; then
            echo "Successfully updated SonarQube project $sqprojectname setting sonar.cs.nunit.reportPaths"
        fi
    else
        echo "Either no SonarQube server or Project Key were given. Please add the report path manually."
    fi
fi

# setup project PR integration
if [[ "$sqserver" != "" || "$sqprojectkey" != "" ]]; then
    echo "Selecting Github ALM"
    resultalmsetting=$(curl --location -u $sqtoken: --request POST "https://$sqserver/api/alm_settings/set_github_binding?project=$sqprojectkey&almSetting=github&repository=$githubrepo")
    if [ -z "$resultalmsetting" ]; then
        echo "Successfully updated SonarQube project $sqprojectname PR decoration settings"
    fi
else
    echo "Either no SonarQube server or Project Key were given. Please setup PR decoration manually."

fi