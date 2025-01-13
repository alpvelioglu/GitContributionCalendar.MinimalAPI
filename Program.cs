using GitContributionCalendar.MinimalAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using Scalar.AspNetCore;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.Json.Serialization.Metadata;

namespace GitContributionCalendar.MinimalAPI
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateSlimBuilder(args);

            builder.Services.AddOpenApi();
            builder.Services.AddHttpClient();
            builder.Services.AddCors();
            //builder.WebHost.UseKestrelHttpsConfiguration();


            builder.Services.ConfigureHttpJsonOptions(options =>
            {
                options.SerializerOptions.TypeInfoResolver = JsonTypeInfoResolver.Combine(
                    AppJsonSerializerContext.Default,
                    options.SerializerOptions.TypeInfoResolver
                );
            });

            var app = builder.Build();

            app.MapOpenApi();
            app.MapScalarApiReference();
            
            //app.UseHttpsRedirection();
            app.UseCors(builder =>
            {
                builder.AllowAnyOrigin();
                builder.AllowAnyHeader();
                builder.AllowAnyMethod();
            });

            app.MapPost("/getcontributions", async (HttpContext httpContext, HttpClient client, [FromBody] BaseRequest request) =>
            {
                client.BaseAddress = new Uri(request.BaseURL);
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", request.BitbucketAPIKey);
                var result = await client.GetAsync($"/rest/awesome-graphs/latest/user/activities/{request.Username}?from=2024-01-01&to=2024-12-31");

                var contributionResponse = new List<ContributionResponse>();
                for (var date = new DateTime(2024, 1, 1); date <= new DateTime(2024, 12, 31); date = date.AddDays(1))
                {
                    contributionResponse.Add(new ContributionResponse
                    {
                        Date = date.ToString("yyyy-MM-dd"),
                        ContributionCount = 0
                    });
                }
                var resultContent = await result.Content.ReadAsStringAsync();
                var resultJson = JsonSerializer.Deserialize(resultContent, AppJsonSerializerContext.Default.DictionaryStringListObject);

                foreach (var date in resultJson!.Keys)
                {
                    var item = contributionResponse.FirstOrDefault(c => c.Date == date);
                    if (item is not null)
                    {
                        item.ContributionCount = resultJson[date].Count;
                    }
                }

                return Results.Ok(contributionResponse);
            });

            app.MapPost("/getuser", async (HttpContext httpContext, HttpClient client, [FromBody] BaseRequest request) =>
            {
                client.BaseAddress = new Uri(request.BaseURL);
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", request.BitbucketAPIKey);
                var result = await client.GetAsync($"/rest/api/latest/users/{request.Username}?avatarSize=64");
                var resultContent = await result.Content.ReadAsStringAsync();
                var user = JsonSerializer.Deserialize(resultContent, AppJsonSerializerContext.Default.UserResponse);

                return Results.Ok(user);
            });

            app.Run();
        }
    }

    [JsonSerializable(typeof(BaseRequest))]
    [JsonSerializable(typeof(ContributionResponse))]
    [JsonSerializable(typeof(UserResponse))]
    [JsonSerializable(typeof(List<ContributionResponse>))]
    [JsonSerializable(typeof(Dictionary<string, List<object>>))]
    internal partial class AppJsonSerializerContext : JsonSerializerContext
    {

    }
}
