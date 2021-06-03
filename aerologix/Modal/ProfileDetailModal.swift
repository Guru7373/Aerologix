//
//  ProfileDetailModal.swift
//  aerologix
//
//  Created by Karthi CK on 02/06/21.
//

import Foundation

public struct ProfileDetailModal: Codable {
    public var data: [Datum]?

    enum CodingKeys: String, CodingKey {
        case data
    }
    
    public init(data: [Datum]?) {
        self.data = data
    }
}

// MARK: - Datum

public struct Datum: Codable {
    let firstname, lastname: String?
    let age: Int?
    let gender: String?
    let picture: String?
    var job: [Job]?
    var education: [Education]?
    var isExpanded: Bool = false
    var isJobExpanded: Bool = false
    var isEducationExpanded: Bool = false

    enum CodingKeys: String, CodingKey {
        case firstname, lastname, age, gender, picture, job, education
    }

    public init(firstname: String?, lastname: String?, age: Int?, gender: String?, picture: String?, job: [Job]?, education: [Education]?) {
        self.firstname = firstname
        self.lastname = lastname
        self.age = age
        self.gender = gender
        self.picture = picture
        self.job = job
        self.education = education
    }
}

// MARK: - Job
public struct Job: Codable {
    let role: String?
    let exp: Int?
    let organization: String?
    
    enum CodingKeys: String, CodingKey {
        case role, exp, organization
    }
    
    public init(role: String?, exp: Int?, organization: String?) {
        self.role = role
        self.exp = exp
        self.organization = organization
    }
}

public struct Education: Codable {
    let degree, institution: String?
    
    enum CodingKeys: String, CodingKey {
        case degree, institution
    }
    
    public init(degree: String?, institution: String?) {
        self.degree = degree
        self.institution = institution
    }
}
