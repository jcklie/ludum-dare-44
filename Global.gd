extends Node

enum Currency {Euro, Dollar, Yen, Pound}

const currencies = [Currency.Euro, Currency.Dollar, Currency.Yen, Currency.Pound]

const colors = {
	Currency.Euro: Color.blue,
	Currency.Dollar: Color.green,
	Currency.Yen: Color.purple,
	Currency.Pound: Color.orange
}

# The skin directory names of the currencies
const skins = {
	Currency.Euro: "eur",
	Currency.Dollar: "usd",
	Currency.Yen: "yen",
	Currency.Pound: "gbp"
}

const symbols = {
	Currency.Euro: "€",
	Currency.Dollar: "$",
	Currency.Yen: "¥",
	Currency.Pound: "£"
}