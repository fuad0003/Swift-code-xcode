import XCTest
@testable import CalorieTracker

final class UserProfileTests: XCTestCase {

    // MARK: - Default Values

    func testDefaultProfile() {
        let profile = UserProfile()
        XCTAssertEqual(profile.name, "My Profile")
        XCTAssertEqual(profile.email, "")
        XCTAssertFalse(profile.isEmailVerified)
        XCTAssertNil(profile.lastCloudSync)
        XCTAssertNil(profile.weightKg)
        XCTAssertNil(profile.baselineWeightKg)
        XCTAssertNil(profile.heightCm)
        XCTAssertNil(profile.age)
        XCTAssertTrue(profile.isMale)
        XCTAssertNil(profile.rawBodyFatPercentage)
        XCTAssertTrue(profile.isSouthAsian)
        XCTAssertEqual(profile.targetBodyFatPercentage, 14.0)
        XCTAssertEqual(profile.activityMultiplier, 1.2)
        XCTAssertEqual(profile.weeklyLossRate, 0.0075)
    }

    // MARK: - correctedBodyFatPercentage

    func testCorrectedBodyFatPercentage_nilWhenRawIsNil() {
        var profile = UserProfile()
        profile.rawBodyFatPercentage = nil
        XCTAssertNil(profile.correctedBodyFatPercentage)
    }

    func testCorrectedBodyFatPercentage_southAsianAdds4Point3() {
        var profile = UserProfile()
        profile.rawBodyFatPercentage = 15.0
        profile.isSouthAsian = true
        XCTAssertEqual(profile.correctedBodyFatPercentage, 19.3, accuracy: 0.01)
    }

    func testCorrectedBodyFatPercentage_nonSouthAsianNoAdjustment() {
        var profile = UserProfile()
        profile.rawBodyFatPercentage = 15.0
        profile.isSouthAsian = false
        XCTAssertEqual(profile.correctedBodyFatPercentage, 15.0, accuracy: 0.01)
    }

    func testCorrectedBodyFatPercentage_zeroRawSouthAsian() {
        var profile = UserProfile()
        profile.rawBodyFatPercentage = 0.0
        profile.isSouthAsian = true
        XCTAssertEqual(profile.correctedBodyFatPercentage, 4.3, accuracy: 0.01)
    }

    // MARK: - fatFreeMassKg

    func testFatFreeMassKg_nilWhenWeightNil() {
        var profile = UserProfile()
        profile.weightKg = nil
        profile.rawBodyFatPercentage = 15.0
        XCTAssertNil(profile.fatFreeMassKg)
    }

    func testFatFreeMassKg_nilWhenBodyFatNil() {
        var profile = UserProfile()
        profile.weightKg = 80.0
        profile.rawBodyFatPercentage = nil
        XCTAssertNil(profile.fatFreeMassKg)
    }

    func testFatFreeMassKg_calculatesCorrectly() {
        var profile = UserProfile()
        profile.weightKg = 80.0
        profile.rawBodyFatPercentage = 15.0
        profile.isSouthAsian = true
        // correctedBF = 15 + 4.3 = 19.3
        // FFM = 80 * (1 - 19.3/100) = 80 * 0.807 = 64.56
        XCTAssertEqual(profile.fatFreeMassKg!, 64.56, accuracy: 0.01)
    }

    func testFatFreeMassKg_nonSouthAsian() {
        var profile = UserProfile()
        profile.weightKg = 80.0
        profile.rawBodyFatPercentage = 20.0
        profile.isSouthAsian = false
        // correctedBF = 20.0 (no adjustment)
        // FFM = 80 * (1 - 20/100) = 80 * 0.80 = 64.0
        XCTAssertEqual(profile.fatFreeMassKg!, 64.0, accuracy: 0.01)
    }

    // MARK: - basalMetabolicRate

    func testBMR_defaultProfile_usesHarrisBenedict() {
        let profile = UserProfile()
        // defaults: w=66.5, h=170, a=23, isMale=true, no FFM
        // wF=665, hF=1062.5, aF=115
        // male: 665 + 1062.5 - 115 + 5 = 1617.5
        XCTAssertEqual(profile.basalMetabolicRate, 1617.5, accuracy: 0.01)
    }

    func testBMR_female_usesHarrisBenedict() {
        var profile = UserProfile()
        profile.isMale = false
        // defaults: w=66.5, h=170, a=23
        // female: 665 + 1062.5 - 115 - 161 = 1451.5
        XCTAssertEqual(profile.basalMetabolicRate, 1451.5, accuracy: 0.01)
    }

    func testBMR_withCustomValues_male() {
        var profile = UserProfile()
        profile.weightKg = 80.0
        profile.heightCm = 180.0
        profile.age = 30
        profile.isMale = true
        // wF=800, hF=1125, aF=150
        // male: 800 + 1125 - 150 + 5 = 1780
        XCTAssertEqual(profile.basalMetabolicRate, 1780.0, accuracy: 0.01)
    }

    func testBMR_withCustomValues_female() {
        var profile = UserProfile()
        profile.weightKg = 60.0
        profile.heightCm = 165.0
        profile.age = 25
        profile.isMale = false
        // wF=600, hF=1031.25, aF=125
        // female: 600 + 1031.25 - 125 - 161 = 1345.25
        XCTAssertEqual(profile.basalMetabolicRate, 1345.25, accuracy: 0.01)
    }

    func testBMR_withFFM_usesKatchMcArdleFormula() {
        var profile = UserProfile()
        profile.weightKg = 80.0
        profile.rawBodyFatPercentage = 15.0
        profile.isSouthAsian = false
        // correctedBF = 15, FFM = 80 * 0.85 = 68
        // BMR = 370 + 21.6 * 68 = 370 + 1468.8 = 1838.8
        XCTAssertEqual(profile.basalMetabolicRate, 1838.8, accuracy: 0.01)
    }

    func testBMR_withFFM_southAsian() {
        var profile = UserProfile()
        profile.weightKg = 80.0
        profile.rawBodyFatPercentage = 15.0
        profile.isSouthAsian = true
        // correctedBF = 19.3, FFM = 80 * 0.807 = 64.56
        // BMR = 370 + 21.6 * 64.56 = 370 + 1394.496 = 1764.496
        XCTAssertEqual(profile.basalMetabolicRate, 1764.496, accuracy: 0.01)
    }

    // MARK: - baseDailyTargetCalories

    func testBaseDailyTargetCalories_defaultProfile() {
        let profile = UserProfile()
        // BMR = 1617.5 (from above)
        // deficit = (66.5 * 0.0075 * 7700) / 7 = (3838.875) / 7 = 548.41
        // adaptation = max(0, 0 - 0) * 121 = 0 (baselineWeightKg defaults to nil -> 0)
        // target = (1617.5 * 1.2) - 548.41 - 0 = 1941.0 - 548.41 = 1392.59
        // floor = 1617.5 * 1.1 = 1779.25
        // max(1392.59, 1779.25) = 1779.25
        XCTAssertEqual(profile.baseDailyTargetCalories, 1779.25, accuracy: 0.01)
    }

    func testBaseDailyTargetCalories_withAdaptation() {
        var profile = UserProfile()
        profile.weightKg = 70.0
        profile.baselineWeightKg = 80.0
        profile.heightCm = 175.0
        profile.age = 25
        profile.isMale = true
        profile.activityMultiplier = 1.5
        profile.weeklyLossRate = 0.005
        // BMR = 10*70 + 6.25*175 - 5*25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
        // deficit = (70 * 0.005 * 7700) / 7 = 2695 / 7 = 385.0
        // adaptation = max(0, 80-70) * 121 = 10 * 121 = 1210
        // target = (1673.75 * 1.5) - 385 - 1210 = 2510.625 - 385 - 1210 = 915.625
        // floor = 1673.75 * 1.1 = 1841.125
        // max(915.625, 1841.125) = 1841.125
        XCTAssertEqual(profile.baseDailyTargetCalories, 1841.125, accuracy: 0.01)
    }

    func testBaseDailyTargetCalories_highActivityNoAdaptation() {
        var profile = UserProfile()
        profile.weightKg = 90.0
        profile.heightCm = 180.0
        profile.age = 30
        profile.isMale = true
        profile.activityMultiplier = 1.9
        profile.weeklyLossRate = 0.003
        // BMR = 10*90 + 6.25*180 - 5*30 + 5 = 900 + 1125 - 150 + 5 = 1880
        // deficit = (90 * 0.003 * 7700) / 7 = 2079 / 7 = 297
        // adaptation = 0 (no baseline)
        // target = 1880 * 1.9 - 297 = 3572 - 297 = 3275
        // floor = 1880 * 1.1 = 2068
        // max(3275, 2068) = 3275
        XCTAssertEqual(profile.baseDailyTargetCalories, 3275.0, accuracy: 0.01)
    }

    func testBaseDailyTargetCalories_neverBelowBMRFloor() {
        var profile = UserProfile()
        profile.weightKg = 100.0
        profile.heightCm = 180.0
        profile.age = 30
        profile.isMale = true
        profile.activityMultiplier = 1.0
        profile.weeklyLossRate = 0.02
        // BMR = 10*100 + 6.25*180 - 5*30 + 5 = 1000+1125-150+5 = 1980
        // deficit = (100 * 0.02 * 7700)/7 = 15400/7 = 2200
        // target = 1980*1.0 - 2200 = -220
        // floor = 1980 * 1.1 = 2178
        // max(-220, 2178) = 2178
        XCTAssertEqual(profile.baseDailyTargetCalories, 2178.0, accuracy: 0.01)
    }

    // MARK: - Codable

    func testProfileEncodeDecode() throws {
        var profile = UserProfile()
        profile.name = "Test User"
        profile.email = "test@example.com"
        profile.weightKg = 75.0
        profile.heightCm = 180.0
        profile.age = 28

        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)

        XCTAssertEqual(decoded.name, "Test User")
        XCTAssertEqual(decoded.email, "test@example.com")
        XCTAssertEqual(decoded.weightKg, 75.0)
        XCTAssertEqual(decoded.heightCm, 180.0)
        XCTAssertEqual(decoded.age, 28)
    }
}
