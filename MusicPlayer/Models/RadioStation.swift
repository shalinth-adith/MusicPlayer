import Foundation

struct RadioStation: Identifiable {
    let id = UUID()
    let name: String
    let genre: String
    let streamURL: String
}

extension RadioStation {

    static let all: [RadioStation] = [
        // BBC
        RadioStation(name: "BBC Radio 1",       genre: "Pop / Chart",     streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one"),
        RadioStation(name: "BBC Radio 2",       genre: "Easy / Pop",      streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_two"),
        RadioStation(name: "BBC Radio 3",       genre: "Classical",       streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_three"),
        RadioStation(name: "BBC Radio 4",       genre: "Talk / News",     streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm"),
        RadioStation(name: "BBC World Service", genre: "World / News",    streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service"),
        // SomaFM
        RadioStation(name: "Groove Salad",      genre: "Ambient / Chill", streamURL: "https://ice1.somafm.com/groovesalad-128-mp3"),
        RadioStation(name: "Drone Zone",        genre: "Ambient",         streamURL: "https://ice1.somafm.com/dronezone-128-mp3"),
        RadioStation(name: "Fluid",             genre: "Chillout",        streamURL: "https://ice1.somafm.com/fluid-128-mp3"),
        RadioStation(name: "Deep Space One",    genre: "Electronic",      streamURL: "https://ice1.somafm.com/deepspaceone-128-mp3"),
        RadioStation(name: "Indie Pop Rocks",   genre: "Indie / Pop",     streamURL: "https://ice1.somafm.com/indiepop-128-mp3"),
        RadioStation(name: "Left Coast 70s",    genre: "Classic Rock",    streamURL: "https://ice1.somafm.com/seventies-128-mp3"),
        // World
        RadioStation(name: "FIP",               genre: "Jazz / Eclectic", streamURL: "https://icecast.radiofrance.fr/fip-midfi.mp3"),
        RadioStation(name: "Radio Paradise",    genre: "Rock / Eclectic", streamURL: "https://stream.radioparadise.com/rock-320"),
        RadioStation(name: "RP Mellow Mix",     genre: "Mellow / Chill",  streamURL: "https://stream.radioparadise.com/mellow-320"),
    ]

    static var grouped: [(label: String, stations: [RadioStation])] {
        [
            ("BBC",    all.filter { $0.name.hasPrefix("BBC") }),
            ("SomaFM", all.filter { ["Groove Salad","Drone Zone","Fluid","Deep Space One","Indie Pop Rocks","Left Coast 70s"].contains($0.name) }),
            ("World",  all.filter { ["FIP","Radio Paradise","RP Mellow Mix"].contains($0.name) }),
        ]
    }
}
