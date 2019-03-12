
import Foundation

public enum NetworkClientResult<T, U> where U: Error {
    case success(T)
    case failure(U)
}
