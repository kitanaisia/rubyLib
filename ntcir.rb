#!ruby
# -*- coding: utf-8 -*-

module NTCIR
    # 
    # delete_slide
    #   文字数が少ないスライド，一貫性の低いスライドを取り除く
    #   
    #   slide_list: 検索対象のファイルリスト
    #   pmi_hash: 2単語間のPMI値を格納した二重ハッシュ
    #   
    #   checked_slide_list: 不要なスライドを取り除いた，検索対象のファイルリスト
    #
    def self.delete_slide(slide_list, pmi_hash)
        min_char = 100
        acceptance_rate = 0.5    # 50%
        
        checked_slide_list = []

        # 文字数によるスクリーニング
        slide_list.each { |slide_path| 
            content = File::open(slide_path).read
            
            if content.length <= 100
                next
            end

            coherency = calc_coherency(content, pmi_hash)
            checked_slide_list.push([ slide_path, coherency ])
        }


        # 一貫性によるスクリーニング
        number_of_accept = (checked_slide_list.length * acceptance_rate).to_int  # 受理するスライドの枚数

        checked_slide_list.sort! { |a,b| b[1]<=>a[1] }
        checked_slide_list.slice!( 0..(number_of_accept-1) )
        checked_slide_list.map!{|elem| elem[0]}
        
        return checked_slide_list
    end

    # 
    # calc_coherency
    #   文章の一貫性を[1,-1]で計算する．
    #
    #   sentence:文章．
    #   pmi_hash:2単語のPMI値を格納した二重ハッシュ
    #
    #   coherency:文章の一貫性
    #
    def self.calc_coherency(sentence, pmi_hash)
        coherency = 0.0
        
        noun_list = getWordList(sentence, "sentence")\
                    .select{|elem| elem[1] == "名詞"}\
                    .map{|elem| elem[0]}

        combination_arr = noun_list.combination(2)\
                               .to_a\
                               .collect{|elem| elem.sort}\
                               .uniq

        combination_arr.each { |combination| 
            word1 = combination[0]
            word2 = combination[1]

            coherency += pmi_hash[word1][word2]
        }

        coherency /= combination_arr.length.to_f

        return coherency
    end

    # 
    # get_sumpmi
    #   文章中の単語のsumPMI値を計算する．
    #
    #   sentence:文章．
    #   pmi_hash:2単語のPMI値を格納した二重ハッシュ
    #
    #   sum_pmi:文章中の単語のsumPMI値を格納したハッシュ
    #
    def self.get_sumPMI(sentence, pmi_hash)
        sum_pmi = Hash::new(0)
            
        noun_list = getWordList(sentence, "sentence")\
                   .select{|elem| elem[1] == "名詞"}\
                   .map{|elem| elem[0]}

        combination_arr = noun_list.combination(2)\
                                   .to_a\
                                   .collect{|elem| elem.sort}\
                                   .uniq

        combination_arr.each { |combination| 
            word_interest = combination[0]
            word_other = combination[1]

            sum_pmi[word_interest] += pmi_hash[word_interest][word_other]
        }

        return sum_pmi
    end
end
