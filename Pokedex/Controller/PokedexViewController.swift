//
//  PokedexViewController.swift
//  Pokedex
//
//  Created by Rick Jacobson on 4/24/21.
//

import UIKit

class PokedexViewController: UIViewController {
    
    let defaultSession = URLSession(configuration: .default)
    
    let pokeTableView = UITableView()
    
    var pokeList: [Pokemon] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        pokeTableView.dataSource = self
        pokeTableView.delegate = self
        
        setupTableView()
        fetchPokemon()


    }
    
    func fetchPokemon() {
        //This should make sure our URL is valid
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/") else {return}
        
        // Create URLRequest object
        let request = URLRequest(url: url)
        
        defaultSession.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
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
                let listFromJSON = try? JSONDecoder().decode([Pokemon].self, from: data!)
                self.pokeList = listFromJSON!
                self.pokeTableView.reloadData()
            } // If this can throw an error why don't we need to catch it??
        }).resume()
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
        cell.textLabel?.text = pokeList[indexPath.row].name
        return cell
    }
    
    
}
