FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
WORKDIR /app
RUN apk add clang binutils musl-dev build-base zlib-static

#FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
#WORKDIR /app

COPY . ./
RUN dotnet restore --runtime liux-musl-x64 GitContributionCalendar.MinimalAPI.csproj
RUN dotnet publish -r linux-musl-x64 -c Release --no-restore -o out GitContributionCalendar.MinimalAPI.csproj

#COPY *.csproj .
#RUN dotnet restore
#COPY . .
#RUN dotnet publish --no-restore -c Release -o out /p:PublishAot=true

FROM base AS final
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["/app/GitContributionCalendar.MinimalAPI"]