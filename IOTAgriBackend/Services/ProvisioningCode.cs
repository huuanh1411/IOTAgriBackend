using System.Security.Cryptography;
using System.Text;

namespace IOTAgriBackend.Services;

public static class ProvisioningCode
{
    private const string Alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    public static string Create() => string.Concat(Enumerable.Range(0, 12)
        .Select(_ => Alphabet[RandomNumberGenerator.GetInt32(Alphabet.Length)]));

    public static string Hash(string code) => Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(code)));

    public static bool Matches(string code, string hash) =>
        CryptographicOperations.FixedTimeEquals(Convert.FromBase64String(Hash(code)), Convert.FromBase64String(hash));
}
