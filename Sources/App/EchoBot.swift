//
//  EchoBot.swift
//  
//
//  Created by Nikolai Trukhin on 29.07.2023.
//

import Foundation
import Botter
import Vapor

class EchoBot {
    public let dispatcher: Botter.Dispatcher
    public let bot: Botter.Bot
    public let updater: Botter.Updater

    public init(settings: Botter.Bot.Settings, app: Application) throws {
        self.bot = try .init(settings: settings)
        self.dispatcher = .init(bot: bot, app: app)
        self.updater = .init(bot: bot, dispatcher: dispatcher)

        dispatcher.add(handler: Botter.MessageHandler(filters: .all, callback: handleMessage))
    }

    func handleMessage(_ update: Botter.Update, context: Botter.BotContextProtocol) throws {
        guard case let .message(message) = update.content else { return }

        guard let params = Botter.Bot.SendMessageParams(to: message, text: message.text) else { return }

        try bot.sendMessage(params, platform: message.platform.any, context: context)
    }
}
