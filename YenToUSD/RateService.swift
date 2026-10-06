import Foundation

enum RateService {
    /// Used when the live rate can't be fetched.
    static let fallbackRate = 149.5

    // Frankfurter: free, no API key, ECB reference rates.
    private static let url = URL(string: "https://api.frankfurter.dev/v1/latest?base=USD&symbols=JPY")!

    private struct Response: Decodable {
        let rates: [String: Double]
    }

    /// Returns yen per dollar from the API, or nil if anything goes wrong.
    /// Tries twice, since the first request after launch occasionally stalls.
    static func fetchLiveRate() async -> Double? {
        if let rate = await fetchOnce() { return rate }
        return await fetchOnce()
    }

    private static func fetchOnce() async -> Double? {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            guard let rate = try JSONDecoder().decode(Response.self, from: data).rates["JPY"], rate > 0 else { return nil }
            return rate
        } catch {
            return nil
        }
    }
}
