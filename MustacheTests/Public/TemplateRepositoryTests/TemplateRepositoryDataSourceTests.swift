// The MIT License
//
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import XCTest
import Mustache

class TemplateRepositoryDataSourceTests: XCTestCase {
    
    func testTemplateRepositoryDataSource() {
        class TestedDataSource: TemplateRepositoryDataSource {
            func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?) -> TemplateID? {
                switch name {
                case "not_found":
                    return nil
                default:
                    return name
                }
            }
            func templateStringForTemplateID(templateID: TemplateID) throws -> String {
                switch templateID {
                case "not_found":
                    fatalError("Unexpected")
                case "error":
                    throw NSError(domain: "TestedDataSource", code: 0, userInfo: nil)
                default:
                    return templateID
                }
            }
        }
        
        let repo = TemplateRepository(dataSource: TestedDataSource())
        var template: Template
        var rendering: String
        
        template = try! repo.template(named: "foo")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "foo")
        
        template = try! repo.template(string: "{{>foo}}")
        rendering = try! template.render()
        XCTAssertEqual(rendering, "foo")
        
        do {
            try repo.template(string: "{{>not_found}}")
            XCTAssert(false)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, GRMustacheErrorDomain)
            XCTAssertEqual(error.code, GRMustacheErrorCodeTemplateNotFound)
        }
        
        do {
            try repo.template(string: "{{>error}}")
            XCTAssert(false)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "TestedDataSource")
        }
    }
    
}
