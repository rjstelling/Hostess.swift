import Foundation
import Hostess

print("Research Biologist Rose Smollett")

let hostess = Hostess()

print("Name: \(hostess.name ?? "Unknown")")
hostess.addresses.forEach {
	print("\t-: \($0)")
}