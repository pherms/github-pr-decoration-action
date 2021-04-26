FROM mcr.microsoft.com/dotnet/sdk:5.0.201

LABEL "com.github.actions.name"="dotnet build"
LABEL "com.github.actions.description"="Dotnet build with Sonarscanner for .NET 5 and pull request decoration support."
LABEL "com.github.actions.icon"="check-square"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/xablu/github-pr-decoration-action"
LABEL "homepage"="https://github.com/xablu"
LABEL "maintainer"="xablu"

# Version numbers of used software
ENV SONAR_SCANNER_DOTNET_TOOL_VERSION=5.0.4 \
    DOTNETCORE_RUNTIME_VERSION=5.0 \
    JRE_VERSION=11

# Add Microsoft Debian apt-get feed 
RUN wget https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb

# Fix JRE Install https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1

# Install the .NET 5 Runtime for SonarScanner.
# The warning message "delaying package configuration, since apt-utils is not installed" is probably not an actual error, just a warning.
# We don't need apt-utils, we won't install it. The image seems to work even with the warning.
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y apt-transport-https \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y aspnetcore-runtime-$DOTNETCORE_RUNTIME_VERSION nuget \
#    && apt-get install -y dotnet-sdk-$DOTNETCORE_RUNTIME_VERSION

# Install Java Runtime for SonarScanner
RUN apt-get install --no-install-recommends -y openjdk-$JRE_VERSION-jre

# Install SonarScanner .NET global tool
RUN dotnet tool install dotnet-sonarscanner --tool-path . --version $SONAR_SCANNER_DOTNET_TOOL_VERSION

# Cleanup
RUN apt-get -q -y autoremove \
    && apt-get -q clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ADD entrypoint.sh /entrypoint.sh

# Enable execution
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
