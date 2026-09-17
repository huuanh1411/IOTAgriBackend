FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["IOTAgriBackend/IOTAgriBackend.csproj", "IOTAgriBackend/"]
RUN dotnet restore "IOTAgriBackend/IOTAgriBackend.csproj"
COPY . .
RUN dotnet publish "IOTAgriBackend/IOTAgriBackend.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "IOTAgriBackend.dll"]
