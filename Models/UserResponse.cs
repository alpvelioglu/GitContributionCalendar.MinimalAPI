using System.Text.Json.Serialization;

namespace GitContributionCalendar.MinimalAPI.Models
{
    public class UserResponse
    {
        [JsonPropertyName("name")]
        public string Name { get; set; }
        [JsonPropertyName("displayName")]
        public string DisplayName { get; set; }
        [JsonPropertyName("avatarUrl")]
        public string AvatarURL { get; set; }
        public string Provider { get; set; }
    }
}
