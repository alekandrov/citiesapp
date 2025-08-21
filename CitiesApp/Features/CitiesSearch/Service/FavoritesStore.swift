import Foundation

protocol FavoritesRepository {
    func isFavorite(id: Int) -> Bool
    func toggle(id: Int)
    func allIDs() -> Set<Int>
}

final class UserDefaultsFavoritesRepository: FavoritesRepository {
    private let key = "fav.cities"
    private var set: Set<Int> {
        didSet { save() }
    }

    init() {
        if let array = UserDefaults.standard.array(forKey: key) as? [Int] {
            set = Set(array)
        } else {
            set = []
        }
    }

    func isFavorite(id: Int) -> Bool { set.contains(id) }

    func toggle(id: Int) {
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
    }

    func allIDs() -> Set<Int> { set }

    private func save() {
        UserDefaults.standard.set(Array(set), forKey: key)
    }
}
