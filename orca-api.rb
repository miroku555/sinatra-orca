#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'pp'
require 'crack' # for xml and json
require 'crack/xml' # for just xml
require 'uri'
require 'net/http'

Net::HTTP.version_1_2


def post(url,opt,body)
  req = Net::HTTP::Post.new(url)
  req.content_length = body.size
  req.content_type = "application/xml" 
  req.body = body
  req.basic_auth(opt[:user], opt[:passwd])

  ret = []
  Net::HTTP.start(opt[:host], opt[:port]) {|http|
    res = http.request(req)
    ret = [res.code,res.body]
  }
  ret
end

def list_patients(opt)
  url = "/api01rv2/patientlst1v2?class=01"
  body = <<-EOF
  <data>
    <patientlst1req type="record">
      <Base_StartDate type="string">2000-01-01</Base_StartDate>
      <Base_EndDate type="string">#{Time.now.strftime("%Y-%m-%d")}</Base_EndDate>
      <Contain_TestPatient_Flag type="string">1</Contain_TestPatient_Flag>
    </patientlst1req>
  </data>
  EOF
  ret = post(url,opt,body)
  if ret.empty?
    put "ret empty"
    return [nil,"http post error"]
  end
  unless ret[0] == "200"
    puts "status code:#{ret[0]}"
    return [nil,"status code:#{ret[0]}" ]
  end

  root = Crack::XML.parse(ret[1])
  result  = root["xmlio2"]["patientlst1res"]["Api_Result"]
  unless result == "00"
    puts "error"
    return [nil,"result:#{result} message:#{message}"]
  end
  root["xmlio2"]["patientlst1res"]["Patient_Information"]
end

def delete_patient(opt,params)
  url = "/orca12/patientmodv2?class=03"
pp params
  body = <<-EOF
<data>
  <patientmodreq type="record">
  <Patient_ID type="string">#{params['id']}</Patient_ID>
  <WholeName type="string">#{params[:whole_name]}</WholeName>
  <WholeName_inKana type="string">#{params[:whole_name_kana]}</WholeName_inKana>
  <BirthDate type="string">#{params[:birth_date]}</BirthDate>
  <Sex type="string">#{params[:sex]}</Sex>
  </patientmodreq>
</data>
  EOF
puts body
  ret = post(url,opt,body)
  if ret.empty?
    put "ret empty"
    return nil
  end
  unless ret[0] == "200"
    puts "status code:#{ret[0]}"
    return nil
  end

  root = Crack::XML.parse(ret[1])
  result  = root["xmlio2"]["patientmodres"]["Api_Result"]
  message = root["xmlio2"]["patientmodres"]["Api_Result_Message"]
  unless result == "00"
    puts "error"
    return [nil,"result:#{result} message:#{message}"]
  end
  pinfo =  root["xmlio2"]["patientmodres"]["Patient_Information"]
  id = pinfo["Patient_ID"]
  [id,"削除しました"]
end

