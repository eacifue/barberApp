FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Barberia.sln ./
COPY Barberia.API/Barberia.API.csproj Barberia.API/
COPY Barberia.Application/Barberia.Application.csproj Barberia.Application/
COPY Barberia.Domain/Barberia.Domain.csproj Barberia.Domain/
COPY Barberia.Infrastructure/Barberia.Infrastructure.csproj Barberia.Infrastructure/
COPY Barberia.Shared/Barberia.Shared.csproj Barberia.Shared/
RUN dotnet restore Barberia.API/Barberia.API.csproj

COPY . .
RUN dotnet publish Barberia.API/Barberia.API.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Barberia.API.dll"]
