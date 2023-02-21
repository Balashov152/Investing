import InvestingFoundation

public struct AccountsPayload: Codable {
    public var accounts: [Account] = []

    public enum CodingKeys: String, CodingKey {
		case accounts = "accounts"
	}

    public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        accounts = try values.decodeIfPresent(forKey: .accounts, default: [])
	}

}
