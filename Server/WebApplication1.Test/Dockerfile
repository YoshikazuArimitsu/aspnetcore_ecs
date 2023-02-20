#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Server.sln", ""]
COPY ["WebApplication1/WebApplication1.csproj", "WebApplication1/"]
COPY ["WebApplication1.Test/WebApplication1.Test.csproj", "WebApplication1.Test/"]
RUN dotnet restore
COPY . .
RUN dotnet build Server.sln -c Debug
RUN mkdir /TestResults

FROM build AS testing
WORKDIR /src
ENTRYPOINT ["dotnet", "test" ,"--collect:\"XPlat Code Coverage\"", "--results-directory", "/TestResults"]

