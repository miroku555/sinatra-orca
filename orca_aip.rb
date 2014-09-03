#!/usr/bin/ruby
# -*- coding: utf-8 -*-

#------ 患者番号一覧取得


require 'crack' # for xml and json
require 'crack/xml' # for just xml
require 'uri'
require 'net/http'

Net::HTTP.version_1_2

def list_patients(opt)

  req = Net::HTTP::Post.new("/api01rv2/patientlst1v2?class=01")
   body = <<-EOF
  <data>
    <patientlst1req type="record">
      <Base_StartDate type="string">2000-01-01</Base_StartDate>
      <Base_EndDate type="string">#{Time.now.strftime("%Y-%m-%d")}</Base_EndDate>
      <Contain_TestPatient_Flag type="string">1</Contain_TestPatient_Flag>
    </patientlst1req>
  </data>
EOF


	
  req.content_length = body.size
  req.content_type = "application/xml" 
  req.body = body
  req.basic_auth(opt[:user], opt[:passwd])
  
  pinfo = []
  Net::HTTP.start(opt[:host], opt[:port]) {|http|
    res = http.request(req)
    unless res.code == 200
      puts "http status:#{res.code} "
      return []  
    end
  root = Crack::XML.parse(res.body)

  resulet= root["xmlio2"]["patientlst1res"]["Api_Result"]
  unless result == "00"
    puts "error"
    return []
  end
  pinfo = root["xmlio2"]["patientlst1res"]["Patient_Information"]
 }
 pinfo
end
