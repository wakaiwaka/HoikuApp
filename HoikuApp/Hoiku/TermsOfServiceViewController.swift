//
//  TermsOfServiceViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/11/11.
//  Copyright © 2018 若原昌史. All rights reserved.
//
import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TermsOfServiceViewController: UIViewController {
    
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var naviBar: UINavigationItem!
    
    var mailAddress:String!
    var password:String!
    var displayName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        agreeButton.titleLabel?.text = "利用規約に同意する"
        
        naviBar.title = "利用規約"
        
        print(mailAddress)
        print(password)
        print(displayName)
        
        
        //利用規約の中身
        self.termsOfServiceLabel.text = """
        利用規約
        この利用規約（以下，「本規約」
        といいます。）はChildMinder
        がこのアプリ上で提供する
        サービス（以下，「本サービス」
        といいます。）
        の利用条件を定めるものです。
        登録ユーザーの皆さま（以下，
        「ユーザー」といいます。）
        には，本規約に従って
        ，本サービスをご利用いただきます。
        
        第1条（適用）
        
        本規約は，ユーザーと当社との
        間の本サービスの利用に関わる一切
        の関係に適用されるものと
        します。
        
        第2条（利用登録）
        
        登録希望者が当社の定める方法
        によって利用登録を申請し，
        当社がこれを承認すること
        によって，利用登録が
        完了するものとします。
        当社は，利用登録の申請者
        に以下の事由が
        あると判断した場合，
        利用登録の申請を承認しない
        ことがあり，
        その理由については一切の開示義務を
        負わないものとします。
        （1）利用登録の申請に際して
        虚偽の事項を届け出た場合
        （2）本規約に違反したことが
        ある者からの申請である場合
        （3）未成年者，成年被後見人，
        被保佐人または被補助人の
        いずれかであり，法定代理人，
        後見人，保佐人または補助人の
        同意等を得ていなかった場合
        （4）反社会的勢力等（暴力団，
        暴力団員，右翼団体，反社会的勢力
        ，その他これに準ずる者を意味
        します。）である，
        または資金提供その他を通じて
        反社会的勢力等の維持，運営
        もしくは経営に協力もしくは
        関与する等反社会的勢力との
        何らかの交流もしくは関与を行って
        いると判断した場合
        （5）その他，利用登録を相当で
        ないと判断した場合
        
        第3条（ユーザーIDおよびパスワード
        の管理）
        
        ユーザーは，自己の責任において，
        本サービスのユーザーID
        およびパスワードを管理するものと
        します。ユーザーは，いかなる場合にも，
        ユーザーIDおよびパスワードを第三者
        に譲渡または貸与することはできません。
        ユーザーIDとパスワードの
        組み合わせが登録情報と一致してログイン
        された場合には，そのユーザーID
        を登録しているユーザー自身に
        よる利用とみなします。
        
        第4条（禁止事項）
        
        ユーザーは，本サービスの利用に
        あたり，以下の行為をしては
        なりません。
        
        （1）法令または公序良俗に違反する行為
        （2）犯罪行為に関連する行為
        （3）サーバーまたはネットワークの
        機能を破壊したり，
        妨害したりする行為
        （4）サービスの運営を妨害する
        おそれのある行為
        （5）他のユーザーに関する個人情報等
        を収集または蓄積する行為
        （6）他のユーザーに成りすます行為
        （7）サービスに関連して，反社会的
        勢力に対して直接または間接に
        利益を供与する行為
        （8）本サービスの他の利用者または
        第三者の知的財産権，肖像権，
        プライバシー，名誉その他の
        権利または利益を侵害する行為
        （9）過度に暴力的な表現，露骨な
        性的表現，人種，国籍，信条，性別，
        社会的身分，門地等による差別につながる
        表現，自殺，自傷行為，薬物乱用を
        誘引または助長する表現，その他反社会的
        な内容を含み他人に不快感を
        与える表現を，投稿または
        送信する行為
        （10）営業，宣伝，広告，勧誘，
        その他営利を目的とする行為，
        性行為やわいせつな行為を目的と
        する行為，面識のない異性との
        出会いや交際を目的とする行為，
        他のお客様に対する嫌がらせや
        誹謗中傷を目的とする行為，
        その他本サービスが予定
        している利用目的と異なる目的で
        本サービスを利用する行為
        （11）宗教活動または宗教団体への
        勧誘行為
        （12）その他，不適切と判断する行為
        
        第5条（本サービスの提供の停止等）
        
        以下のいずれかの事由があると判断した場合
        ，ユーザーに事前に通知することなく
        本サービスの全部または一部の提供を
        停止または中断することができるものと
        します。
        （1）本サービスにかかるコンピュータ
        システムの保守点検または更新を
        行う場合
        （2）地震，落雷，火災，停電または
        天災などの不可抗力により，本サービスの
        提供が困難となった場合
        （3）コンピュータまたは通信回線等が
        事故により停止した場合
        （4）その他，当社が本サービスの提供
        が困難と判断した場合は，本サービスの
        提供の停止または中断により，
        ユーザーまたは第三者が被ったいかなる
        不利益または損害について，
        理由を問わず一切の責任を負わないもの
        とします。
        
        第6条（著作権）
        
        ユーザーは，自ら著作権等の必要な
        知的財産権を有するか，または必要な
        権利者の許諾を得た文章，画像や映像等の
        情報のみ，本サービスを利用し，投稿または
        編集することができるものとします。
        ユーザーが本サービスを利用して投稿または
        編集した文章，画像，映像等の著作権については，
        当該ユーザーその他既存の権利者に
        留保されるものとします。
        ただし、本サービスを利用して投稿または
        編集された文章，画像，映像等を利用できる
        ものとし，ユーザーは，この利用に関して，
        著作者人格権を行使しないもの
        とします。前項本文の定めるものを除き，
        本サービスおよび本サービスに関連する
        一切の情報についての著作権および
        その他知的財産権はその利用を許諾した
        権利者に帰属し，ユーザーは無断で
        複製，譲渡，貸与，翻訳，改変，転載，
        公衆送信(送信可能化を含みます。），
        伝送，配布，出版，営業使用等を
        してはならないものとします。
        
        第7条（利用制限および登録抹消）
        
        以下の場合には，事前の通知なく，
        投稿データを削除し，ユーザーに対して
        本サービスの全部もしくは一部
        の利用を制限しまたはユーザーとしての
        登録を抹消することができるものとします。
        （1）本規約のいずれかの条項に違反した場合
        （2）登録事項に虚偽の事実があることが
        判明した場合
        （3）破産，民事再生，会社更生または特別清算
        の手続開始決定等の申立がなされたとき
        （4）1年間以上本サービスの利用がない場合
        （5）問い合わせその他の回答を求める連絡に
        対して30日間以上応答がない場合
        （6）第2条第2項各号に該当する場合
        （7）その他，当社が本サービスの利用を
        適当でないと判断した場合
        前項各号のいずれかに該当した場合，ユーザー
        は，一切の債務について期限の利益を失い，
        その時点において負担する一切の債務を
        直ちに一括して弁済しなければなりません。
        本条に基づき
        当社が行った行為によりユーザーに
        生じた損害について，一切の責任を負いません。
        
        第8条（保証の否認および免責事項）
        
        当社は，本サービスに事実上または法律上の
        瑕疵（安全性，信頼性，正確性，完全性，
        有効性，特定の目的への適合性，
        セキュリティなどに関する欠陥，エラーやバグ，
        権利侵害などを含みます。）が
        ないことを明示的にも黙示的にも保証して
        おりません。本サービスに
        起因してユーザーに生じたあらゆる損害に
        ついて一切の責任を負いません。
        ただし，本サービスに関するユーザーとの
        間の契約（本規約を含みます。）
        が消費者契約法に定める消費者契約と
        なる場合，この免責規定は
        適用されません。前項ただし書に定める
        場合であっても，運営側
        （重過失を除きます。）による債務不履行
        または不法行為によりユーザーに生じた
        損害のうち特別な事情から生じた損害
        （当社またはユーザーが損害発生につき予見
        し，または予見し得た場合を含みます。）
        について一切の責任を負いません。また，
        当社の過失（重過失を除きます。）
        による債務不履行または不法行為により
        ユーザーに生じた損害の賠償は，ユーザーから
        当該損害が発生した月に受領した利用料の
        額を上限とします。
        本サービスに関して，ユーザーと他のユーザー
        または第三者との間において生じた取引，
        連絡または紛争等について一切責任を負い
        ません。
        
        第9条（サービス内容の変更等）
        
        ユーザーに通知することなく，本サービスの
        内容を変更しまたは本サービスの提供を
        中止することができるものとし，
        これによってユーザーに
        生じた損害について一切の責任を負いません。
        
        第10条（利用規約の変更）
        
        当社は，必要と判断した場合には，ユーザー
        に通知することなくいつでも本規約
        を変更することができるものとします。
        
        第11条（通知または連絡）
        
        ユーザーと当社との間の通知または連絡は，
        運営の定める方法によって行うものとします。
        
        第12条（権利義務の譲渡の禁止）
        
        ユーザーは，書面による事前の承諾なく，
        利用契約上の地位または本規約に基づく
        権利もしくは義務を第三者に譲渡し，
        または担保に供することはできません。
        
        第13条（準拠法・裁判管轄）
        
        本規約の解釈にあたっては，日本法を準拠法
        とします。
        本サービスに関して紛争が生じた場合には，
        運営の本店所在地を管轄する裁判所を
        専属的合意管轄とします。
        """
    }
    
    //利用規約に同意するのボタンを押した時の処理
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}