FROM mcr.microsoft.com/dotnet/sdk:9.0 AS base
WORKDIR /source

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       clang \
       zlib1g-dev \
       libgcc-11-dev \
       libc6-dev \
       musl-dev \
       musl-tools \
       build-essential \
       binutils \
       lld \
       gcc \
       cmake \
       libstdc++-11-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . .
RUN dotnet publish -r linux-x64 -c Release \
    --self-contained true \
    -p:PublishAot=true \
    -p:OptimizationPreference=Size \
    -p:LinkerFlavor=lld \
    -p:IlcInvariantGlobalization=true \
    -o /app GitContributionCalendar.MinimalAPI.csproj

FROM mcr.microsoft.com/dotnet/runtime-deps:9.0
WORKDIR /app
COPY --from=base /app .

RUN chmod +x /app/GitContributionCalendar.MinimalAPI

EXPOSE 8090

ENTRYPOINT ["./GitContributionCalendar.MinimalAPI"]