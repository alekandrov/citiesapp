import Foundation

final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()
    
    @Published private(set) var ids: Set<Int> = []
    private let key = "misFavoritos"
    
    private init() { load() }
    
    func toggle(id: Int) {
        if ids.contains(id) { ids.remove(id) }
        else { ids.insert(id) }
        save()
    }
    
    func contains(id: Int) -> Bool { ids.contains(id) }
    
    private func load() {
        if let array = UserDefaults.standard.array(forKey: key) as? [Int] {
            ids = Set(array)
        }
    }
    
    private func save() {
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
}
