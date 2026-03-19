# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

# Copy only project files first (better caching)
COPY ../apps/dotnet-service/MyApp/*.csproj ./MyApp/
WORKDIR /dotnet-services/MyApp
RUN dotnet restore

# Copy rest of source
COPY ../apps/dotnet-service/MyApp/. .

RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0

WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080

CMD ["dotnet", "MyApp.dll"]