# == Schema Information
#
# Table name: members
#
#  id             :integer          not null, primary key
#  name           :string           default(""), not null
#  birthday       :date             not null
#  gender         :string           default(""), not null
#  phone          :string           default(""), not null
#  skin           :string
#  hair           :string
#  avatar         :string
#  remark         :string
#  member_code    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  email          :string           default(""), not null
#  fax            :string
#  password       :string
#  group          :string
#  zip            :string
#  county         :string
#  address        :string
#  bonus          :integer          default(0)
#  skin_type_id   :integer
#  hair_id        :integer
#  hair_code      :string
#  hair_type_id   :integer
#  member_type_id :integer
#

class Member < ApplicationRecord
  mount_uploader :avatar, PhotoUploader
  
  belongs_to :skin_type
  belongs_to :hair_type
  belongs_to :member_type
  has_many :orders
  
  def self.to_csv
    zh_attr = %w{姓名 生日 性別 email 電話 傳真 會員群組 郵遞區號 居住縣市 居住地址 紅利點數  膚質 髮質}
    attributes = %w{name birthday gender email phone fax member_code zip county address bonus }
    CSV.generate(headers: true) do |csv|
      csv << zh_attr

      all.each do |member|
        data = member.attributes.values_at(*attributes)
        data << member.skin_type.value << member.hair_type.value
        csv << data
      end
    end
  end

  def self.update_by_file(file)
    attribute = Hash["姓名" => "name" ,
                    "電話" => "phone",
                    "性別" => "gender",
                    "email" => "email",
                    "生日" => "birthday",
                    "傳真" => "fax",
                    "會員群組" => "member_code",
                    "郵遞區號" => "zip",
                    "居住縣市" => "county",
                    "居住地址" => "address",
                    "紅利點數" => "bonus",
                    "請問您是如何認識茶籽堂" => "info_way_id",
                    "您的膚質為何" => "skin_type",
                    "您的髮質為何" => "hair_type"                    
                    ]
    sheet = Roo::Spreadsheet.open(file.path)
    header = sheet.row(1)
    header.each_with_index do |val, index|
      header[index] = attribute[val]
    end

    for i in 2..sheet.last_row()
      row = Hash[[header,sheet.row(i)].transpose]
      member = find_by(phone: row["phone"]) || new
      
      member.attributes = row.to_hash
      
      member.status = "listing" 
      member.save!
    end
  end
  end
end
