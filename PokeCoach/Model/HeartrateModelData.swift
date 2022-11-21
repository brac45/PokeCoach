//
//  HeartrateModel.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/11/22.
//

import SwiftUI

class HeartrateModelData: NSObject, ObservableObject, XMLParserDelegate {
    // Published states
    @Published var datapoints: [HeartrateDataPoint]
    @Published var activityName: String
    
    // Published chart attributes
    @Published var yMax: Int
    @Published var yMin: Int
    
    @Published var xMax: Double
    @Published var xMin: Double
    
    // Constants
    private let NO_ACTIVITIES: String = "No Activity Selected"
    
    // For parsing
    struct TrackPointState {
        var finished: Bool = true
        var hr: Int = -1
        var time: String = ""
    }
    
    private func resetTrkpt () {
        self.currentTrackPoint.finished = true
        self.currentTrackPoint.hr = -1
        self.currentTrackPoint.time = ""
    }
    
    private var currentTrackPoint: TrackPointState
    private var elementNames = ["time", "ns3:hr"]
    private var shouldStoreCharacters = false
    private var currentString: String = ""
    
    override init() {
        self.datapoints = []
        self.activityName = NO_ACTIVITIES
        self.currentTrackPoint = TrackPointState()
        
        self.yMax = 200
        self.yMin = 80
        
        self.xMax = 100.0
        self.xMin = 0.0
        
        super.init()
        
        self.clearAndfillWithGPXData(filename: SampleData.Run1)
    }
    
    func setChartAttributesWithCurrentData() {
        if let maxPoint = self.datapoints.max(by: {$0.hr < $1.hr}) {
            yMax = ((maxPoint.hr/10)*10)+10
            print(yMax)
        }
        if let minPoint = self.datapoints.min(by: {$0.hr < $1.hr}) {
            yMin = ((minPoint.hr/10)*10)-10
            print(yMin)
        }
        self.xMin = 0.0
        self.xMax = Double(self.datapoints.count - 1)
    }

    func clearAllData() {
        self.datapoints.removeAll()
        self.activityName = NO_ACTIVITIES
        self.yMax = 200
        self.yMin = 80
    }
    
    func clearAndfillWithDummyData() {
        self.clearAllData()
        
        self.activityName = "DUMMY DATA"
        self.datapoints = [
            .init(hr: 100, isoDateString: "2022-11-17T11:27:48.000Z"),
            .init(hr: 139, isoDateString: "2022-11-17T11:28:56.000Z"),
            .init(hr: 152, isoDateString: "2022-11-17T11:29:37.000Z"),
            .init(hr: 142, isoDateString: "2022-11-17T11:30:27.000Z"),
            .init(hr: 121, isoDateString: "2022-11-17T11:41:35.000Z")
        ]
        self.setChartAttributesWithCurrentData()
    }
    
    func clearAndfillWithGPXData(filename: SampleData) {
        self.clearAllData()
        
        /// Read file
        if let gpxUrl = Bundle.main.url(forResource: filename.rawValue, withExtension: "gpx") {
            print("XML Resource found, creating xmlparser...")
            if let parser = XMLParser(contentsOf: gpxUrl) {
                print("XMLParser created, parsing...")
                parser.delegate = self
                parser.parse()
                if filename == SampleData.Run1 {
                    self.activityName = "Morning Run"
                }
                self.setChartAttributesWithCurrentData()
            }
        } else {
            print("GPX Parsing Error, reverting to dummy data..")
            self.clearAndfillWithDummyData()
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("Parser started parsing document")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Parser successfully completed parsing")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "trkpt" {
            self.currentTrackPoint.finished = false
            //print("START: \(elementName)")
        } else if elementNames.contains(elementName)  {
            // Start building current string once element of interest is found
            self.currentString = ""
            self.shouldStoreCharacters = true
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !self.currentTrackPoint.finished {
            switch elementName {
            case "trkpt":
                self.datapoints.append(HeartrateDataPoint(hr: currentTrackPoint.hr, isoDateString: currentTrackPoint.time))
                self.resetTrkpt()
                //print("END: \(elementName)")
                break
            case "time":
                currentTrackPoint.time = currentString
                //print("time: \(currentString)")
                break
            case "ns3:hr":
                if let val = Int(currentString) {
                    currentTrackPoint.hr = val
                }
                //print("hr: \(currentString)")
                break
            default:
                break
            }
            shouldStoreCharacters = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if shouldStoreCharacters == true {
            currentString += string
        }
    }
    
    static func getStringPathForGPXData(filename: SampleData) -> String {
        if let path = Bundle.main.path(forResource: filename.rawValue, ofType: "gpx") {
            return path
        } else {
            return "UNKNOWN_PATH"
        }
    }
}

struct HeartrateDataPoint: Identifiable {
    let id: UUID
    let hr: Int
    let ts: Date
    
    init(hr: Int, isoDateString: String) {
        self.id = UUID()
        self.hr = hr
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions.insert(.withFractionalSeconds)
        
        if let buf = isoFormatter.date(from: isoDateString) {
            self.ts = buf
        } else {
            self.ts = Date()
        }
    }
}

enum SampleData: String {
    case Run1 = "sample_run_1"
    case Run2 = "sample_run_2"
    case Run3 = "sample_run_3"
}
