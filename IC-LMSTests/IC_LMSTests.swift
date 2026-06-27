import Testing
@testable import IC_LMS

@Suite("PredefinedSkillLibrary")
struct PredefinedSkillLibraryTests {

    @Test func libraryIsNotEmpty() {
        #expect(!PredefinedSkillLibrary.all.isEmpty)
    }

    @Test func skillIDsAreUnique() {
        let ids = PredefinedSkillLibrary.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func everySkillHasAnchors() {
        for skill in PredefinedSkillLibrary.all {
            #expect(!skill.defaultAnchors.isEmpty)
        }
    }

    @Test func lookupByIDReturnsMatchingSkill() {
        let first = PredefinedSkillLibrary.all[0]
        #expect(PredefinedSkillLibrary.skill(withID: first.id) == first)
        #expect(PredefinedSkillLibrary.skill(withID: "does-not-exist") == nil)
    }
}
