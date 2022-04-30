
import Foundation

/// Chord addresses all possible combinations of simultaneous MIDI notes.
struct Chord {

    var noteSet = BitSet128()

    init(notes: [Note]) {
        for n in notes {
            add(note: n)
        }
    }

    init(noteNumbers: [Int]) {
        for n in noteNumbers {
            noteSet.add(bit: n)
        }
    }

    var noteCount: Int {
        notes.count
    }

    var isDyad: Bool {
        noteCount == 2
    }

    var isTriad: Bool {
        noteCount == 3
    }

    var notes: [Note] {
        var r: [Note] = []
        forEachNote({ r.append($0)})
        return r
    }

    /// Calls a function for each note in the chord.
    func forEachNote(_ f: (Note) -> ()) {
        noteSet.forEach { bit in
            f(Note(noteNumber: Int8(bit)))
        }
    }

    /// Add a note to a chord.
    mutating func add(note: Note) {
        noteSet.add(bit: Int(note.noteNumber))
    }

    /// Is a note in a chord?
    func contains(note: Note) -> Bool {
        noteSet.isSet(bit: Int(note.noteNumber))
    }

    /// One-sided Hausdorff distance to another chord.
    ///
    /// https://en.wikipedia.org/wiki/Hausdorff_distance
    func hausdorff(to: Chord) -> Int {
        var d_sup = 0
        self.forEachNote { n0 in
            var d_inf = Int.max
            to.forEachNote { n1 in
                d_inf = min(d_inf, n0.semitones(to: n1))
            }
            d_sup = max(d_sup, d_inf)
        }
        return d_sup
    }

    /// Get the notes in the chord using a Key to name them.
    func notes(in key: Key) -> [Note] {
        var r: [Note] = []
        noteSet.forEach { noteNumber in
            r.append(Note(noteNumber: Int8(noteNumber), key: key))
        }
        return r
    }
    
    /// Get the notes in the chord using a Key to name them.
    func noteSet(in key: Key) -> NoteSet {
        var r = NoteSet()
        noteSet.forEach { noteNumber in
            r.add(note: Note(noteNumber: Int8(noteNumber), key: key))
        }
        return r
    }

    /// Try to give this chord a name in a particular key.
    func name(in key: Key) -> String {

        let table = ChordTable.shared
        let hash = pitchClassesHash(in: key)

        if let root = table.minorTriadRoots[hash] {
            return "\(root.spelling)m"
        }

        if let root = table.majorTriadRoots[hash] {
            return root.spelling
        }

        if let root = table.diminishedTriadRoots[hash] {
            return "\(root.spelling)°"
        }

        if let root = table.augmentedTriadRoots[hash] {
            return "\(root.spelling)⁺"
        }

        return "unknown chord"
    }

    func pitchClassesHash(in key: Key) -> Int {
        var r = NoteSet()
        noteSet.forEach { noteNumber in
            r.add(note: Note(noteNumber: Int8(noteNumber), key: key).pitchClass)
        }
        return r.hashValue
    }

}

/// A table of note sets so we can look up chord names.
class ChordTable {

    static let shared = ChordTable()

    static func hashPitchClasses(notes: [Note?]) -> Int {
        var r = NoteSet()
        for note in notes {
            if let note = note {
                r.add(note: note.pitchClass)
            }
        }
        return r.hashValue
    }
    
    static func generateTriads(shifts: [Interval]) -> [Int: Note] {
        var r: [Int: Note] = [:]
        let accidentals: [Accidental] = [.flat, .natural, .sharp]
        for accidental in  accidentals {
            for letter in Letter.allCases {
                let root = Note(letter, accidental: accidental)
                r[ChordTable.hashPitchClasses(notes: [root, root.shift(shifts[0]), root.shift(shifts[1])])] = root
            }
        }
        print("generated \(r.count) triads")
        return r
    }

    lazy var majorTriadRoots: [Int: Note] = ChordTable.generateTriads(shifts: [.M3, .P5])
    lazy var minorTriadRoots: [Int: Note] = ChordTable.generateTriads(shifts: [.m3, .P5])
    lazy var diminishedTriadRoots: [Int: Note] = ChordTable.generateTriads(shifts: [.m3, .d5])
    lazy var augmentedTriadRoots: [Int: Note] = ChordTable.generateTriads(shifts: [.M3, .A5])

}

/// A set of intervals from the root (tonic).
struct ChordType: OptionSet {
    let rawValue: Int

    var intervals: [Interval] {

        var result: [Interval] = []
        for i in 0..<11 {
            if (rawValue >> i) & 1 != 0 {
                result.append(Interval(rawValue: i)!)
            }
        }
        return result
    }

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(intervals: [Interval]) {
        var r = 0
        for interval in intervals {
            r |= (1 << interval.rawValue)
        }
        self.rawValue = r
    }

    static let majorTriad = ChordType(intervals: [.M3, .P5])
    static let majorSixth = ChordType(intervals: [.M3, .P5, .M6])
    static let dominantSeventh = ChordType(intervals: [.M3, .P5, .m7])
    static let minorTriad = ChordType(intervals: [.m3, .P5])
}
