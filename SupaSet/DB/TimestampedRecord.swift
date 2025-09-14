//
//  TimestampedRecord.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/26/25.
//

import GRDB
import SwiftUI
/// A record type that tracks its creation and modification dates. See
/// <https://swiftpackageindex.com/groue/GRDB.swift/documentation/grdb/recordtimestamps>
protocol TimestampedRecord: MutablePersistableRecord {
    var creationDate: Date? { get set }
    var modificationDate: Date? { get set }
}


extension TimestampedRecord {
    /// By default, `TimestampedRecord` types set `creationDate` and
    /// `modificationDate` to the transaction date, if they are nil,
    /// before insertion.
    ///
    /// `TimestampedRecord` types that customize the `willInsert`
    /// persistence callback should call `initializeTimestamps` from
    /// their implementation.
    mutating func willInsert(_ db: Database) throws {
        try initializeTimestamps(db)
    }
    
    /// Sets `creationDate` and `modificationDate` to the transaction date,
    /// if they are nil.
    ///
    /// It is called automatically before insertion, if your type does not
    /// customize the `willInsert` persistence callback. If you customize
    /// this callback, call `initializeTimestamps` from your implementation.
    mutating func initializeTimestamps(_ db: Database) throws {
        if creationDate == nil {
            creationDate = try db.transactionDate
        }
        if modificationDate == nil {
            modificationDate = try db.transactionDate
        }
    }
    
    /// Sets `modificationDate`, and executes an `UPDATE` statement
    /// on all columns.
    ///
    /// - parameter modificationDate: The modification date. If nil, the
    ///   transaction date is used.
    mutating func updateWithTimestamp(_ db: Database, modificationDate: Date? = nil) throws {
        self.modificationDate = try modificationDate ?? db.transactionDate
        try update(db)
    }
    
    /// Modifies the record according to the provided `modify` closure, and,
    /// if and only if the record was modified, sets `modificationDate` and
    /// executes an `UPDATE` statement that updates the modified columns.
    ///
    /// For example:
    ///
    /// ```swift
    /// try dbQueue.write { db in
    ///     var player = Player.find(db, id: 1)
    ///     let modified = try player.updateChangesWithTimestamp(db) {
    ///         $0.score = 1000
    ///     }
    ///     if modified {
    ///         print("player was modified")
    ///     } else {
    ///         print("player was not modified")
    ///     }
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - db: A database connection.
    ///     - modificationDate: The modification date. If nil, the
    ///       transaction date is used.
    ///     - modify: A closure that modifies the record.
    /// - returns: Whether the record was changed and updated.
    @discardableResult
    mutating func updateChangesWithTimestamp(
        _ db: Database,
        modificationDate: Date? = nil,
        modify: (inout Self) -> Void)
    throws -> Bool
    {
        // Grab the changes performed by `modify`
        let initialChanges = try databaseChanges(modify: modify)
        if initialChanges.isEmpty {
            return false
        }
        
        // Update modification date and grab its column name
        let dateChanges = try databaseChanges(modify: {
            $0.modificationDate = try modificationDate ?? db.transactionDate
        })
        
        // Update the modified columns
        let modifiedColumns = Set(initialChanges.keys).union(dateChanges.keys)
        try update(db, columns: modifiedColumns)
        return true
    }
    
    /// Sets `modificationDate`, and executes an `UPDATE` statement that
    /// updates the `modificationDate` column, if and only if the record
    /// was modified.
    ///
    /// - parameter modificationDate: The modification date. If nil, the
    ///   transaction date is used.
    mutating func touch(_ db: Database, modificationDate: Date? = nil) throws {
        try updateChanges(db) {
            $0.modificationDate = try modificationDate ?? db.transactionDate
        }
    }
}
