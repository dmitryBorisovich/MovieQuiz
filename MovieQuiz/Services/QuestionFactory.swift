import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    private weak var delegate: QuestionFactoryDelegate?

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.items.isEmpty {
                        self.delegate?.didLoadIncorrectData()
                    } else {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            let task = URLSession.shared.dataTask(with: movie.resizedImageURL) { data, response, error in
                
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.delegate?.didFailToLoadImage()
                    }
                    return
                }
                
                guard let imageData = data else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.delegate?.didFailToLoadImage()
                    }
                    return
                }
                
                let rating = Float(movie.rating) ?? 0
                let numberToCompare = Int.random(in: 7...9)
                let comparisonWord = ["больше", "меньше"].randomElement() ?? "больше"
                let text = "Рейтинг этого фильма \(comparisonWord), чем \(numberToCompare)?"
                let correctAnswer = comparisonWord == "больше" ? rating > Float(numberToCompare) : rating < Float(numberToCompare)
                
                let question = QuizQuestion(
                    image: imageData,
                    text: text,
                    correctAnswer: correctAnswer
                )
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
            
            task.resume()
        }
    }
}
