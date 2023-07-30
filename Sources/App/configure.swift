import Vapor
import Botter
import Telegrammer
import Vkontakter

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try configureEchoBotter(app)

    // register routes
    try routes(app)
}

private func configureEchoBotter(_ app: Application) throws {
    let botterSettings = Botter.Bot.Settings(
        vk: vkSettings(app),
        tg: tgSettings(app)
    )
    let bot = try EchoBot(settings: botterSettings, app: app)
    try bot.updater.startWebhooks(vkServerName: Constants.vkServerName).wait()
}

func tgSettings(_ app: Application) -> Telegrammer.Bot.Settings {
    var tgSettings = Telegrammer.Bot.Settings(token: Constants.tgToken, debugMode: !app.environment.isRelease)
    tgSettings.webhooksConfig = .init(ip: "0.0.0.0", baseUrl: app.webhooksUrl(for: .tg), port: app.serverPort(for: .tg))
    debugPrint("Starting tg webhooks on url \(tgSettings.webhooksConfig?.url ?? "nope") port \(tgSettings.webhooksConfig?.port ?? -1)")
    return tgSettings
}

func vkSettings(_ app: Application) -> Vkontakter.Bot.Settings {
    var vkSettings: Vkontakter.Bot.Settings = .init(token: Constants.vkToken, debugMode: !app.environment.isRelease)
    vkSettings.webhooksConfig = .init(ip: "0.0.0.0", baseUrl: app.webhooksUrl(for: .vk), port: app.serverPort(for: .vk), groupId: Constants.vkGroupId)
    debugPrint("Starting vk webhooks on url \(vkSettings.webhooksConfig?.url ?? "nope") port \(vkSettings.webhooksConfig?.port ?? -1)")
    return vkSettings
}

extension Application {
    func webhooksPort(for platform: AnyPlatform) -> Int {
        switch platform {
        case .tg:
            return Constants.tgWebhooksPort

        case .vk:
            return Constants.vkWebhooksPort
        }
    }

    func serverPort(for platform: AnyPlatform) -> Int {
        let port: Int
        switch platform {
        case .tg:
            port = Constants.tgServerPort

        case .vk:
            port = Constants.vkServerPort
        }
        return port
    }

    func webhooksUrl(for platform: AnyPlatform) -> String {
        let url: URL = Constants.webhooksUrl
        let port = self.webhooksPort(for: platform)
        return "\(url):\(port)"
    }
}
