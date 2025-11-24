//
//  FlagManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import UIKit

final class FlagManager
{
    static let shared = FlagManager()

    //Mapping of country names to their ISO 3166-1 alpha-2 codes.
    private let countryCodeMap: [String: String] = [
        "Afghanistan": "af", "Aland Islands": "ax", "Albania": "al", "Algeria": "dz",
        "American Samoa": "as", "Andorra": "ad", "Angola": "ao", "Anguilla": "ai",
        "Antarctica": "aq", "Antigua and Barbuda": "ag", "Argentina": "ar", "Armenia": "am",
        "Aruba": "aw", "Australia": "au", "Austria": "at", "Azerbaijan": "az",
        "Bahamas": "bs", "Bahrain": "bh", "Bangladesh": "bd", "Barbados": "bb",
        "Belarus": "by", "Belgium": "be", "Belize": "bz", "Benin": "bj",
        "Bermuda": "bm", "Bhutan": "bt", "Bolivia": "bo", "Bosnia and Herzegovina": "ba",
        "Botswana": "bw", "Brazil": "br", "Brunei Darussalam": "bn", "Bulgaria": "bg",
        "Burkina Faso": "bf", "Burundi": "bi", "Cabo Verde": "cv", "Cambodia": "kh",
        "Cameroon": "cm", "Canada": "ca", "Cayman Islands": "ky", "Central African Republic": "cf",
        "Chad": "td", "Chile": "cl", "China": "cn", "Colombia": "co", "Comoros": "km",
        "Congo": "cg", "Democratic Republic of the Congo": "cd", "Costa Rica": "cr",
        "Croatia": "hr", "Cuba": "cu", "Cyprus": "cy", "Czech Republic": "cz",
        "Denmark": "dk", "Djibouti": "dj", "Dominica": "dm", "Dominican Republic": "do",
        "Ecuador": "ec", "Egypt": "eg", "El Salvador": "sv", "Estonia": "ee",
        "Eswatini": "sz", "Ethiopia": "et", "Fiji": "fj", "Finland": "fi", "France": "fr",
        "Germany": "de", "Ghana": "gh", "Greece": "gr", "Greenland": "gl",
        "Guatemala": "gt", "Guinea": "gn", "Guyana": "gy", "Haiti": "ht", "Honduras": "hn",
        "Hong Kong": "hk", "Hungary": "hu", "Iceland": "is", "India": "in",
        "Indonesia": "id", "Iran": "ir", "Iraq": "iq", "Ireland": "ie", "Israel": "il",
        "Italy": "it", "Jamaica": "jm", "Japan": "jp", "Jordan": "jo", "Kazakhstan": "kz",
        "Kenya": "ke", "Kuwait": "kw", "Kyrgyzstan": "kg", "Laos": "la",
        "Latvia": "lv", "Lebanon": "lb", "Lesotho": "ls", "Liberia": "lr", "Libya": "ly",
        "Liechtenstein": "li", "Lithuania": "lt", "Luxembourg": "lu",
        "Macau": "mo", "Madagascar": "mg", "Malawi": "mw", "Malaysia": "my",
        "Maldives": "mv", "Mali": "ml", "Malta": "mt", "Marshall Islands": "mh",
        "Mauritania": "mr", "Mauritius": "mu", "Mexico": "mx", "Moldova": "md",
        "Monaco": "mc", "Mongolia": "mn", "Montenegro": "me", "Morocco": "ma",
        "Mozambique": "mz", "Myanmar": "mm", "Namibia": "na", "Nepal": "np",
        "Netherlands": "nl", "New Zealand": "nz", "Nicaragua": "ni", "Niger": "ne",
        "Nigeria": "ng", "North Korea": "kp", "North Macedonia": "mk",
        "Norway": "no", "Oman": "om", "Pakistan": "pk", "Palestine": "ps",
        "Panama": "pa", "Papua New Guinea": "pg", "Paraguay": "py",
        "Peru": "pe", "Philippines": "ph", "Poland": "pl", "Portugal": "pt",
        "Qatar": "qa", "Romania": "ro", "Russia": "ru", "Rwanda": "rw",
        "Saudi Arabia": "sa", "Senegal": "sn", "Serbia": "rs", "Seychelles": "sc",
        "Sierra Leone": "sl", "Singapore": "sg", "Slovakia": "sk", "Slovenia": "si",
        "South Africa": "za", "South Korea": "kr", "Spain": "es", "Sri Lanka": "lk",
        "Sudan": "sd", "Sweden": "se", "Switzerland": "ch", "Syria": "sy",
        "Taiwan": "tw", "Tanzania": "tz", "Thailand": "th", "Togo": "tg",
        "Trinidad and Tobago": "tt", "Tunisia": "tn", "Turkey": "tr",
        "Uganda": "ug", "Ukraine": "ua", "United Arab Emirates": "ae",
        "United Kingdom": "gb", "United States": "us", "Uruguay": "uy",
        "Uzbekistan": "uz", "Venezuela": "ve", "Vietnam": "vn",
        "Zambia": "zm", "Zimbabwe": "zw",
        "Bonaire, Sint Eustatius and Saba": "bq", "Bouvet Island": "bv", "British Indian Ocean Territory": "io",
        "Christmas Island": "cx", "Cocos (Keeling) Islands": "cc", "Cook Islands": "ck", "Curaçao": "cw",
        "Equatorial Guinea": "gq", "Eritrea": "er", "Falkland Islands": "fk", "Faroe Islands": "fo",
        "Federated States of Micronesia": "fm", "French Guiana": "gf", "French Polynesia": "pf",
        "French Southern Territories": "tf", "Gabon": "ga", "Gambia": "gm", "Gibraltar": "gi",
        "Guadeloupe": "gp", "Guam": "gu", "Guernsey": "gg", "Guinea-Bissau": "gw",
        "Heard Island and McDonald Islands": "hm", "Holy See": "va", "Isle of Man": "im",
        "Jersey": "je", "Kiribati": "ki", "Martinique": "mq", "Mayotte": "yt",
        "Montserrat": "ms", "New Caledonia": "nc", "Niue": "nu", "Norfolk Island": "nf",
        "Northern Mariana Islands": "mp", "Pitcairn": "pn", "Réunion": "re",
        "Saint Barthélemy": "bl", "Saint Helena, Ascension and Tristan da Cunha": "sh",
        "Saint Kitts and Nevis": "kn", "Saint Lucia": "lc", "Saint Martin": "mf",
        "Saint Pierre and Miquelon": "pm", "Saint Vincent and the Grenadines": "vc",
        "Samoa": "ws", "San Marino": "sm", "Sao Tome and Principe": "st",
        "Sint Maarten": "sx", "Solomon Islands": "sb", "Somalia": "so",
        "South Georgia and the South Sandwich Islands": "gs", "South Sudan": "ss",
        "Suriname": "sr", "Svalbard and Jan Mayen": "sj", "Timor-Leste": "tl",
        "Tokelau": "tk", "Tonga": "to", "Turkmenistan": "tm", "Turks and Caicos Islands": "tc",
        "Tuvalu": "tv", "United States Minor Outlying Islands": "um", "Vanuatu": "vu",
        "Virgin Islands (British)": "vg", "Virgin Islands (U.S.)": "vi", "Wallis and Futuna": "wf",
        "Western Sahara": "eh", "Yemen": "ye",
        "Ascension Island": "sh-ac", "Association of Southeast Asian Nations": "asean", "Basque Country": "es-pv",
        "Canary Islands": "ic", "Catalonia": "es-ct", "Central European Free Trade Agreement": "cefta",
        "Clipperton Island": "cp", "Diego Garcia": "dg", "East African Community": "eac",
        "England": "gb-eng", "Europe": "eu", "Galicia": "es-ga", "Kosovo": "xk",
        "League of Arab States": "arab", "Northern Ireland": "gb-nir", "Pacific Community": "pc",
        "Saint Helena": "sh-hl", "Scotland": "gb-sct", "Tristan da Cunha": "sh-ta",
        "United Nations": "un", "Unknown": "xx", "Wales": "gb-wls"
    ]

    //Returns the flag image for a given country name.
    func getCountryFlagImage(_ countryName: String) -> UIImage?
    {
        guard let code = countryCodeMap[countryName] else { return nil }
        return UIImage(named: code)
    }

}

