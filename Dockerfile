FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish --no-restore -c Release -o out /p:PublishAot=true

FROM base AS final
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "GitContributionCalendar.MinimalAPI"]