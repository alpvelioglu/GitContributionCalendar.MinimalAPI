FROM mcr.microsoft.com/dotnet/sdk:9.0 AS base
#WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       clang zlib1g-dev

#FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
#WORKDIR /app

WORKDIR /source

COPY . .
RUN dotnet publish -o /app GitContributionCalendar.MinimalAPI.csproj
#RUN dotnet publish -r linux-musl-x64 -c Release --no-restore -o out GitContributionCalendar.MinimalAPI.csproj

#COPY *.csproj .
#RUN dotnet restore
#COPY . .
#RUN dotnet publish --no-restore -c Release -o out /p:PublishAot=true

FROM mcr.microsoft.com/dotnet/runtime-deps:9.0
WORKDIR /app
COPY --from=base /app .
ENTRYPOINT ["/app/GitContributionCalendar.MinimalAPI"]

#FROM base AS final
#WORKDIR /app
#COPY --from=build /app/out .
#ENTRYPOINT ["/app/GitContributionCalendar.MinimalAPI"]