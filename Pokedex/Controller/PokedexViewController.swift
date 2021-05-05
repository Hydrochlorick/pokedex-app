//
//  PokedexViewController.swift
//  Pokedex
//
//  Created by Rick Jacobson on 4/24/21.
//

import UIKit
import Kingfisher

class PokedexViewController: UIViewController {
    
    let defaultSession = URLSession(configuration: .default)
    
    let pokeTableView = UITableView()
    
    private var pokeList: [PokemonData] = []
    private var nextPage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        pokeTableView.dataSource = self
        pokeTableView.delegate = self
        
        setupTableView()
        fetchPokemonList(withPage: nextPage)
    }
    
    func fetchPokemonList(withPage page: String?) {
        var url: URL!
        if let pageURL = page {
            url = URL(string: pageURL)
        } else {
            url = URL(string: "https://pokeapi.co/api/v2/pokemon/")
        }
        
        let request = URLRequest(url: url)
        let dataTask = defaultSession.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            // Make sure it worked
            guard error == nil else {
                print("Error: ", error!)
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            
            let pokeResult = try? JSONDecoder().decode(PokemonResult.self, from: data)
//            print(pokeResult!)
            self.nextPage = pokeResult?.next
            for pokemon in pokeResult!.results {
                print(pokemon.url)
                self.fetchPokemonData(withUrl: pokemon.url) { (pokemon) in
                    self.pokeList.append(pokemon)
                    DispatchQueue.main.async {
                        self.pokeTableView.reloadData()
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    func fetchPokemonData(withUrl url: String, completion: @escaping(PokemonData) -> ()) {
        guard let url = URL(string: url) else {return}
        let request = URLRequest(url: url)
        let session = URLSession.shared
        session.dataTask(with: request){ (data,result,error) in
            // Make sure it worked
            guard error == nil else {
                print("Error: ", error!)
                return
            }
            guard data != nil else {
                print("No data received")
                return
            }
            do {
                let jsonData = try JSONDecoder().decode(PokemonData.self, from: data!)
                print(jsonData)
                print("We're here")
                completion(jsonData)
            } catch {
                print(data!)
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    func setupTableView() {
        view.addSubview(pokeTableView)
        
        pokeTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pokeTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pokeTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pokeTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pokeTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

}

extension PokedexViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pokeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        let pokemon = pokeList[indexPath.row]
        cell.textLabel?.text = pokemon.name
        cell.detailTextLabel?.text = String(pokemon.id)
        if let image = pokemon.sprites?.frontDefault, let url = URL(string: image) {
            cell.imageView?.kf.setImage(with: url)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == pokeList.count {
            fetchPokemonList(withPage: nextPage)
        }
    }
}
