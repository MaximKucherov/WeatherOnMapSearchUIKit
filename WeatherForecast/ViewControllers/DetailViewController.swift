//
//  WeatherDetailViewController.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 03/12/2023.
//

import UIKit

class DetailViewController: UIViewController, UINavigationControllerDelegate {
    
    var cityLocation: FilterService? {
        didSet {
            updateDetails()
            updateButton()
        }
    }
    
    var icon: UIImage?
    var humidity: Int?
    var temperature: Double?
    
    let dateLabel = UILabel()
    let cityLabel = UILabel()
    let temperatureLabel = UILabel()
    let descriptionLabel = UILabel()
    
    private let feelsLikeLabel = UILabel()
    private let addOrDelFavoriteButton = UIButton()
    private let storageManager = StorageManager.shared
    private let viewModel = DetailViewModel()

//    let daysOfWeek = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Updating weather information when loading the screen
        updateDayToday()
        updateDetails()
        
        // Adjust the image in the Navigation Controller to return to the previous screen
        configureBackButton()
}
    
    // MARK: - Overrive Methods (Setup TabBar)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the tabbar
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show tabbar before leaving the screen
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
    }
    
    // MARK: - Setup UI
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupUI() {
        
        // Stack - date today and city name
        dateLabel.textColor = .gray
        cityLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        cityLabel.textColor = .white
        let dateCityStackView = UIStackView(arrangedSubviews: [dateLabel, cityLabel])
        dateCityStackView.axis = .vertical
        view.addSubview(dateCityStackView)
        
        dateCityStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateCityStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateCityStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateCityStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        // Stack - Temperatura, Description and Feels Like
        temperatureLabel.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        temperatureLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        descriptionLabel.textColor = .white
        feelsLikeLabel.textColor = .gray
        let tempDiscFeelStackView = UIStackView(arrangedSubviews: [temperatureLabel, descriptionLabel, feelsLikeLabel])
        tempDiscFeelStackView.axis = .vertical
        
        view.addSubview(tempDiscFeelStackView)
        tempDiscFeelStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tempDiscFeelStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tempDiscFeelStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tempDiscFeelStackView.topAnchor.constraint(equalTo: dateCityStackView.bottomAnchor, constant: 40)
        ])
        
        // TableView UI
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tempDiscFeelStackView.bottomAnchor, constant: 32),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 44 * 6)
        ])
        
        // Button for add/delete to/from favorite VC
        addOrDelFavoriteButton.isUserInteractionEnabled = true
        addOrDelFavoriteButton.setTitleColor(.purple, for: .normal)
        view.addSubview(addOrDelFavoriteButton)
        addOrDelFavoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addOrDelFavoriteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            addOrDelFavoriteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        
        updateButton()
    }
    
    private func updateButton() {
        if storageManager.fetchData().contains(where: { storedEntity in
            return storedEntity.name == cityLocation?.name &&
            storedEntity.lat == cityLocation?.lat &&
            storedEntity.lon == cityLocation?.lon &&
            storedEntity.country == cityLocation?.country &&
            storedEntity.state == cityLocation?.state
        }) {
            addOrDelFavoriteButton.setTitle(NSLocalizedString("Delete from favorite", comment: ""), for: .normal)
        } else {
            addOrDelFavoriteButton.setTitle(NSLocalizedString("Add to favorite", comment: ""), for: .normal)
        }
        addOrDelFavoriteButton.addTarget(self, action: #selector(addOrDelFavorite), for: .touchUpInside)
    }
    
    // MARK: - Private Methods
    @objc private func addOrDelFavorite() {
        guard let city = cityLocation?.name,
              let latitude = cityLocation?.lat,
              let longitude = cityLocation?.lon,
              let country = cityLocation?.country,
              let state = cityLocation?.state else { return }
        
        if let existingEntity = storageManager.fetchData().first(where: { storedEntity in
            return storedEntity.name == city &&
            storedEntity.lat == latitude &&
            storedEntity.lon == longitude &&
            storedEntity.country == country &&
            storedEntity.state == state
        }) {
            // The object is found, we delete it
            showAlert(with: "\(existingEntity.name ?? ""), \(existingEntity.country ?? "")", and: NSLocalizedString("has been removed from favorites", comment: ""))
            storageManager.delete(existingEntity)
            addOrDelFavoriteButton.setTitle(NSLocalizedString("Add to favorite", comment: ""), for: .normal)
        } else {
            // The object was not found, we are adding it
            storageManager.save(city, latitude, longitude, country, state) { cityCountryEntity in
                showAlert(with: "\(cityCountryEntity.name ?? ""), \(cityCountryEntity.country ?? "")", and: NSLocalizedString("has been added to favorites", comment: ""))
            }
            addOrDelFavoriteButton.setTitle(NSLocalizedString("Delete from favorite", comment: ""), for: .normal)
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UpdateUI
    
    private func updateDayToday() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    private func updateDetails() {
        guard let latitude = cityLocation?.lat, let longitude = cityLocation?.lon else { return }
        self.cityLabel.text = cityLocation?.name
        
        viewModel.updateDetailWeather(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let detailData):
                self.temperature = detailData.main?.temp
                self.humidity = detailData.main?.humidity
                
                guard let description = detailData.weather?.first?.description else { return }
                guard let feelsLike = detailData.main?.feels_like else { return }
                guard let icon = detailData.weather?.first?.icon else { return }
                
                self.viewModel.getFetchImage(iconCode: icon) { result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self.icon = image
                            self.tableView.reloadData()
                        }
                    case .failure(let failure):
                        print("Error: \(failure)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.temperatureLabel.text = "\(Int((self.temperature ?? 0) - 273.15))°C"
                    
                    let firstCharacter = description.prefix(1).uppercased()
                    let restOfTheString = description.dropFirst()
                    let descriptionText = firstCharacter + restOfTheString
                    self.descriptionLabel.text = descriptionText
                    
                    let feelsLikeText = "\(Int(feelsLike - 273.15))°C"
                    self.feelsLikeLabel.text = NSLocalizedString("Feels like", comment: "") + " \(feelsLikeText)"
                }
                
            case .failure(let failure):
                print("Error: \(failure)")
            }
        }
    }

    private func configureBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        backButton.tintColor = .purple
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

    // MARK: - TableView
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailTableViewCell
        
        let tomorrow = Date().adding(days: 1)
        if let day = Calendar.current.date(byAdding: .day, value: indexPath.row, to: tomorrow) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let dayOfWeek = formatter.string(from: day)
            cell.weekDayLabel.text = NSLocalizedString(dayOfWeek.capitalized, comment: "")
        }
        
        cell.iconImage.image = self.icon
        
        // The values are random because OpenWeatherMap does't provide this data for free
        let randomHumidity = viewModel.getRandomHumidity(humidity: humidity ?? 0)
        cell.percentLabel.text = "\(randomHumidity)%"
        
        let randomTemp = viewModel.getRandomTemp(temperature: temperature ?? 0)
        cell.temperatureLabel.text = "\(randomTemp)°C"
        
        cell.backgroundColor = .clear

        return cell
    }
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}
