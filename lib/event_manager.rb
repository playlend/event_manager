require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
=begin	
	if zipcode.nil?
		zipcode = "00000"
	elsif zipcode.length < 5
		zipcode = zipcode.rjust 5, "0"
	elsif zipcode.length > 5
		zipcode = zipcode[0..4]
	else
		zipcode
	end
=end
	zipcode.to_s.rjust(5,"0")[0..4]	

end

def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def clean_phone_numbers(phone)
	phone = phone.scan(/\d/).join('')

	if phone.length >= 10 && phone.length <= 11 
		if phone.length == 11 && phone[0].to_i == 1
			phone = phone[1..phone.length]
		end
		phone
	end

end

def days_of_week
	days = {"sunday" => 0,
			"monday" => 0,
			"tuesday" => 0,
			"wednesday" => 0,
			"thursday" => 0,
			"friday" => 0, 
			"saturday" => 0 }

end


def day_hour(reg_date, days, hours)
	date = DateTime.strptime(reg_date, '%m/%d/%y %H:%M')
	
	case 
		when date.sunday?
			days["sunday"] = days["sunday"] + 1
			hours.push(date.hour)
		when date.monday?
			days["monday"] = days["monday"] + 1
			hours.push(date.hour)
		when date.tuesday?
			days["tuesday"] = days["tuesday"] + 1
			hours.push(date.hour)
		when date.wednesday?
			days["wednesday"] = days["wednesday"] + 1
			hours.push(date.hour)
		when date.thursday?
			days["thursday"] = days["thursday"] + 1
			hours.push(date.hour)
		when date.friday?
			days["friday"] = days["friday"] + 1
			hours.push(date.hour)
		when date.saturday?
			days["saturday"] = days["saturday"] + 1
			hours.push(date.hour)
	end


end


def best_day_hour(days, hours)
	peak_day = days.key(days.values.max)

	freq = hours.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
	peak_hour = hours.max_by { |v| freq[v] }
	
end


def save_thank_you_letters(id, form_letter)
	Dir.mkdir("output") unless Dir.exists?("output")
	filename = "output/thanks_#{id}.html"
	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end



contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb.html"
erb_template = ERB.new template_letter

days = days_of_week
hours = []


contents.each do |row|
	id = row[0]
	name = row[:first_name]
	phone = row[:homephone]
	reg_date = row[:regdate]
	zipcode = clean_zipcode(row[:zipcode])


	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)
	
	phone = clean_phone_numbers(phone)

	day_hour(reg_date, days, hours)
	
	


	
	#save_thank_you_letters(id, form_letter)	

end

 best_day_hour(days, hours)
