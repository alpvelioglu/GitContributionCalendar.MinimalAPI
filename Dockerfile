FROM mcr.microsoft.com/dotnet/sdk:9.0 AS base
WORKDIR /source

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       clang zlib1g-dev libgcc-11-dev libc6-dev musl-dev musl-tools \
    && rm -rf /var/lib/apt/lists/*

# Copy source and publish
COPY . .
RUN dotnet publish -r linux-musl-x64 -c Release \
    --self-contained true -p:PublishAot=true \
    -o /app GitContributionCalendar.MinimalAPI.csproj

# Final image
FROM mcr.microsoft.com/dotnet/runtime-deps:9.0
WORKDIR /app
COPY --from=base /app .
ENTRYPOINT ["/app/GitContributionCalendar.MinimalAPI"]