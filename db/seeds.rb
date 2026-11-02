# Shared exercises are read-only to users. Running seeds repeatedly is safe.
%w[ベンチプレス スクワット デッドリフト ショルダープレス ラットプルダウン シーテッドロー レッグプレス ダンベルカール 腕立て伏せ 懸垂].each do |name|
  Exercise.find_or_create_by!(name: name, user_id: nil)
end
