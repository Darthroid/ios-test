//
//  SubscriptionsViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/20/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift
import DifferenceKit

class SubscriptionsViewModel {
    var subscriptions: Results<Subscription>? {
        let results = Subscription.all(onlyJoined: !searchState.isSearching)
		return hasLastMessage ? results?.sortedByLastMessageDate() : results?.sortedByRoomUpdatedAt()
    }

    enum SearchState {
        case searching(query: String)
        case notSearching

        var isSearching: Bool {
            switch self {
            case .searching:
                return true
            case .notSearching:
                return false
            }
        }
    }

	var filterType: SubscriptionFilteringOption = .all {
		didSet {
			buildSections()
		}
	}
    var searchStateUpdated: ((_ oldValue: SearchState, _ searchState: SearchState) -> Void)?
    var searchState: SearchState = .notSearching {
        didSet {
            searchStateUpdated?(oldValue, searchState)
        }
    }

    var assorter: RealmAssorter<Subscription>? {
        willSet {
            assorter?.invalidate()
        }
    }

    var reloadNotificationToken: NotificationToken?
    let realm: Realm?

    init(realm: Realm? = Realm.current) {
        self.realm = realm
        observeAuth()
    }

    deinit {
        assorter?.invalidate()
    }

    func observeAuth() {
        reloadNotificationToken = realm?.objects(Auth.self).observe({ [weak self] _ in
            if self?.realm?.objects(Auth.self).count == 1 {
                DispatchQueue.main.async {
                    self?.updateVisibleCells?()
                }
            }
        })
    }

    func buildSections() {
        if let realm = realm, assorter == nil {
            assorter = RealmAssorter<Subscription>(realm: realm)
            assorter?.didUpdateIndexPaths = didUpdateIndexPaths
        }

        guard
            let queryBase = subscriptions,
            let assorter = assorter
        else {
            return
        }

        assorter.willReconstructSections()

        switch searchState {
        case .searching(let query):
            let queryData = queryBase.filterBy(name: query)
            assorter.registerSection(name: localized("subscriptions.search_results"), objects: queryData)

            API.current()?.client(SpotlightClient.self).search(query: query) { _, _ in }
            assorter.registerModel(model: queryData)
        case .notSearching:
            var queryItems = queryBase

			func filtered(using predicates: [String]) -> Results<Subscription> {
				let predicates = predicates
					.map { NSPredicate(format: $0) }
				let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
				let filteredResult = queryItems.filter(compoundPredicate)//filter(predicate)
				queryItems = queryItems.filter(compoundPredicate.negation)

				return filteredResult
			}

			let queryData: Results<Subscription>

			switch self.filterType {
			case .all:
				queryData = filtered(using: [
					String(format: "privateType == '%@'", SubscriptionType.directMessage.rawValue),
					String(format: "privateType == '%@'", SubscriptionType.channel.rawValue),
					String(format: "privateType == '%@'", SubscriptionType.group.rawValue)
				])
			case .chats:
				queryData = filtered(using: [
					String(format: "privateType == '%@'", SubscriptionType.directMessage.rawValue)
				])
			case .communities:
				queryData = filtered(using: [
					String(format: "privateType == '%@'", SubscriptionType.channel.rawValue),
					String(format: "privateType == '%@'", SubscriptionType.group.rawValue)
				])
			}

			assorter.registerSection(name: "", objects: queryData)
            assorter.registerModel(model: queryBase)
        }
    }

    var didUpdateIndexPaths: RealmAssorter<Subscription>.IndexPathsChangesEvent? {
        didSet {
            assorter?.didUpdateIndexPaths = self.didUpdateIndexPaths
        }
    }

    var updateVisibleCells: (() -> Void)?
}

// MARK: TableView

extension SubscriptionsViewModel {

    var hasLastMessage: Bool {
        return AuthSettingsManager.settings?.storeLastMessage ?? true
    }

    var numberOfSections: Int {
        return assorter?.numberOfSections ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return assorter?.numberOfRowsInSection(section) ?? 0
    }

    func titleForHeaderInSection(_ section: Int) -> String {
        return assorter?.nameForSection(section) ?? "error"
    }

    func heightForHeaderIn(section: Int) -> Double {
        let numberOfRows = numberOfRowsInSection(section)
        let title = titleForHeaderInSection(section)

        return numberOfRows > 0 && !title.isEmpty ? 55 : 0
    }

    func absoluteIndexForIndexPath(_ indexPath: IndexPath) -> Int {
        return (0..<indexPath.section).reduce(0, { index, section in
            return index + numberOfRowsInSection(section)
        }) + indexPath.row
    }

    func indexPathForAbsoluteIndex(_ index: Int) -> IndexPath? {
        var count = 0
        let sections = (0..<numberOfSections).map({
            (0..<numberOfRowsInSection($0))
        }).enumerated()

        for (section, rows) in sections {
            if index > count + rows.count - 1 {
                count += rows.count
            } else {
                return IndexPath(row: index - count, section: section)
            }
        }

        return nil
    }

    func subscriptionForRowAt(indexPath: IndexPath) -> Subscription.UnmanagedType? {
        guard
            numberOfSections > indexPath.section,
            indexPath.section >= 0,
            numberOfRowsInSection(indexPath.section) > indexPath.row,
            indexPath.row >= 0
        else {
            return nil
        }

        return assorter?.objectForRowAtIndexPath(indexPath)
    }

}

private extension NSPredicate {
    var negation: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: self)

    }
}
