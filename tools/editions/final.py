import json
c=json.load(open('candidates.json'))
S={ # book: (commons [(文件名, 说明)], IA [(id, 说明)])
"kant-cpr":([("Kant-KdrV-1781.png","1781 年初版（A 版）扉页，里加：哈特克诺赫出版")],[("bub_gb_gHk9AAAAcAAJ","1791 年第四版，法兰克福"),("immanuelkantscri01kant","1881 年 Max Müller 英译本，伦敦麦克米伦")]),
"hegel-phen":([("Phänomenologie des Geistes.jpg","1807 年初版扉页，班贝格与维尔茨堡")],[("systemderwissen00hegegoog","1807 年初版《科学体系·第一部：精神现象学》"),("phnomenologied00hege","1907 年 Lasson 校订本，莱比锡")]),
"hegel-logic":([("Wissenschaft der Logik.jpg","初版扉页，纽伦堡：施拉格")],[("wissenschaftder03hegegoog","1812 年初版，纽伦堡"),("bub_gb_XHGx2e_KLOYC","1833 年《黑格尔全集》本，柏林：东克尔与洪堡")]),
"russell-denoting":([("On Denoting.jpg","《心灵》（Mind）1905 年第 14 卷所载《论指称》")],[]),
"russell-pm":([("Russell, Whitehead - Principia Mathematica to 56.jpg","《数学原理》（至 ✱56）"),("Principia Mathematica 54-43.png","第一卷 ✱54.43：由此可证 1+1=2")],[("cu31924001575244","1910 年初版第一卷，剑桥大学出版社")]),
"russell-problems":([("Russell title1912.jpg","1912 年初版扉页")],[("problemsofphilos00russuoft","1912 年初版，伦敦：威廉斯与诺盖特"),("problemsofphilo00russuoft","1912 年美国版，纽约：霍尔特")]),
"lunyu":([("Manuscript of Lunyu, text by Kong Anguo with commentary by Zheng Xuan.jpg","唐代写本《论语》郑玄注"),("Commentary on The Analects of Confucius WDL11839.jpg","16 世纪《论语》注本（世界数字图书馆藏）")],[("06081456.cn","朱熹《四书章句集注·论语集注》卷一至卷六"),("06043734.cn","皇侃《论语集解义疏》卷一至卷二"),("02075220.cn","刘宝楠《论语正义》（一）")]),
"daodejing":([("Mawangdui LaoTsu Ms2.JPG","马王堆汉墓帛书《老子》（西汉）")],[("06049303.cn","《老子道德经》上篇"),("06048948.cn","《道德真经注》卷一至卷二"),("02092040.cn","严遵《道德真经指归》（一）")]),
"zhuangzi":([("Zhuangzi Tian Yun Ms.JPG","唐写本《庄子·天运》（8 世纪）"),("Zhuangzi Song Edition.jpg","宋刻本《庄子》")],[("06048962.cn","郭象《庄子注》卷一至卷二"),("02092140.cn","郭庆藩《庄子集释》（一）")]),
"mengzi":([("Jiatai Era Mencius title page.jpg","南宋嘉泰年间刻本《孟子》"),("Mencius published in Edo period Japan.jpg","日本江户时代刊本《孟子》（约 1632 年）")],[("06081458.cn","朱熹《四书章句集注·孟子集注》卷一至卷二"),("06072986.cn","赵岐注、孙奭疏《孟子注疏》"),("02075282.cn","焦循《孟子正义》（一）")]),
"hanfeizi":([],[("06072346.cn","《韩非子》卷一至卷四"),("02092483.cn","王先慎《韩非子集解》（一）")]),
"zhuziyulei":([],[("06049689.cn","《朱子语类》卷一至卷二"),("06049690.cn","《朱子语类》卷三至卷四")]),
"mozi":([],[("06076356.cn","《墨子》卷一至卷四"),("02095513.cn","孙诒让《墨子间诂》（一）")]),
"xunzi":([],[("02091525.cn","王先谦《荀子集解》（一）"),("02091526.cn","王先谦《荀子集解》（二）")]),
"chunqiufanlu":([],[("06072286.cn","《春秋繁露》卷一至卷六"),("02075125.cn","苏舆《春秋繁露义证》（一）")]),
"apology":([],[("dialoguesplato05platgoog","1876 年乔伊特（Jowett）译《柏拉图对话集》第一卷"),("dialogueofplato00platuoft","1900 年《柏拉图对话集》：含《申辩篇》《克里同》《斐多》")]),
"republic":([("Politeia beginning. Codex Parisinus graecus 1807.jpg","巴黎希腊文抄本 1807 号：《理想国》开篇（约 900 年）"),("P. Oxy. LII 3679.jpg","俄克喜林库斯纸草 3679：《理想国》残片（3 世纪）")],[("a604578400platuoft","1888 年乔伊特译本，牛津：克拉伦登出版社")]),
"phaedo":([("Olympiodorus the Younger, Venice, Gr. 196.jpg","小奥林匹奥多罗斯《斐多》注疏抄本（约 900 年，威尼斯）")],[("phaedofoplato00platuoft","1883 年《斐多》，伦敦：麦克米伦"),("trialanddeathofs00platiala","1895 年《苏格拉底的审判与死亡》（含《斐多》）")]),
"symposium":([("Plato Symposium papyrus.jpg","《会饮》纸草残片")],[("symposiumofplato01plat","1909 年《会饮》，剑桥：赫弗父子")]),
"confessions":([("Basel, Universitätsbibliothek, A IV 4, f. 1r – Aurelius Augustinus, Confessiones.JPG","巴塞尔大学图书馆藏《忏悔录》抄本首页"),("Confessiones-UBU Hs. 41-f.001r-Tronende Augustinus met een hart doorboort met pijlen.jpg","乌得勒支大学藏《忏悔录》抄本（15 世纪）")],[("confessionssaug00pusegoog","1838 年蒲赛（Pusey）英译本，牛津")]),
"discourse":([("Page de titre de la première édition du discours de la méthode.jpg","1637 年初版扉页，莱顿：让·迈尔")],[("discoursdelamet00desca","1637 年初版，莱顿"),("discoursdelameth00desc","1658 年巴黎版")]),
"meditationes":([("Meditationes de prima philosophia 1641.jpg","1641 年初版扉页，巴黎")],[("ned-kbn-all-00003573-001","1642 年阿姆斯特丹第二版，埃尔泽维尔"),("bub_gb_ZZibllqkgCQC","1644 年阿姆斯特丹版，布劳")]),
"ethics":([],[("ned-kbn-all-00004303-001","1677 年《遗著集》（Opera Posthuma）初版，《伦理学》首次刊行"),("ethica00unkngoog","1905 年拉丁文本，海牙：奈霍夫")]),
"enquiry":([],[("enquiryconcernin01hume","1900 年 Open Court 版，芝加哥")]),
"nicomachean":([("Aristoteles, De moribus, Johannes Argyropulos interpres.Aristoteles, Aeconomica, Leonardus Brunus interpres.Aristoteles, Politica, Leonardus Brunus interpres","15 世纪拉丁文抄本：阿吉罗波洛斯译《伦理学》")],[("cu31924028995914","1847 年英译本，牛津"),("petersethics00arisrich","1886 年 Peters 英译本，伦敦")]),
"politics":([("Aristotle, Politics, Udine 258.jpg","15 世纪中叶《政治学》抄本（乌迪内）"),("Politica 1481 Aristóteles.jpg","1481 年刊本《政治学》")],[("aristotlespolit00elligoog","1895 年埃利斯（Ellis）英译本，伦敦：劳特利奇")]),
"summa":([("Basel, Universitätsbibliothek, A I 14, Head – Thomas Aquinas, Summa theologiae (prima pars","巴塞尔大学藏《神学大全》第一集抄本（15 世纪）")],[("summatheologi01thom","1912 年英国多明我会英译本第一卷，伦敦")]),
"monadologie":([("Leibniz Monadology 1.jpg","《单子论》书页")],[("monadologie00zimmgoog","1847 年德译本，维也纳"),("la-monadologie-lachelier-1919","1919 年 Lachelier 校订法文本")]),
"tractatus":([("Tractatus title page.jpg","1922 年德英对照初版扉页，伦敦：凯根·保罗"),("Start of Tractatus Logico-Philosophicus.jpg","1922 年版正文开篇：1 世界是一切发生的事情")],[("in.ernet.dli.2015.218527","1922 年伦敦初版（印度数字图书馆扫描）")]),
"zhouyi":([("I Ching Song Dynasty print.jpg","宋刻本《周易》")],[("06070838.cn","朱熹《原本周易本义》卷一至卷二"),("06075217.cn","《周易本义》卷首至卷一")]),
"guanzi":([],[("06081560.cn","《管子》卷一至卷三"),("02092471.cn","戴望《管子校正》（一）")]),
"sunzi":([],[("02092175.cn","《十一家注孙子》（一）"),("artofwaroldestmi00suntuoft","1910 年翟林奈（Giles）英译本，伦敦")]),
"liji":([],[("06073258.cn","《礼记注疏》卷三十七至卷三十八")]),
"liezi":([],[("06076369.cn","《列子》卷一至卷四"),("02092156.cn","《列子》（一）")]),
"lunheng":([],[("06073461.cn","《论衡》卷一至卷二")]),
"zhouyuangong":([("太極圖.jpg","周敦颐《太极图》")],[("06053510.cn","《周元公集》卷一至卷四")]),
"zhangzi":([],[("06071413.cn","《张子全书》卷一至卷二（含《西铭》《正蒙》）")]),
"ercheng":([],[("06071429.cn","《二程遗书》卷一至卷二下")]),
"xiangshan":([],[("06058125.cn","《象山集》卷一至卷三")]),
"rizhilu":([],[("06061656.cn","《日知录》卷一")]),
"lucretius":([("Lucretius, De rerum natura.jpg","1483 年刊本《物性论》"),("Lucretius - De rerum natura, first lines Leiden VLF 30, 9th century.jpg","莱顿藏 9 世纪抄本开篇")],[("dererumnatura00lucr","1889 年剑桥大学出版社版")]),
"enchiridion":([("Epictetus Enchiridion 1683 page1.jpg","1683 年刊本《手册》首页"),("Epicteti Enchiridion Latinis versibus adumbratum (Oxford 1715) frontispiece.jpg","1715 年牛津拉丁诗体本卷首插画")],[("allworksofepicte00epic","1759 年《爱比克泰德全集》英译本，都柏林")]),
"meditations":([],[("meditationsofmar00marc","1887 年英译本，伦敦"),("meditations00marcuoft","1906 年 Everyman 版，伦敦：登特")]),
"prince":([],[("4R581INV679","1532 年罗马初版，布拉多印行"),("8K4INV80RES_P2","1535 年刊本")]),
"leviathan":([],[("leviathan00hobba","1651 年伦敦初版，克鲁克印行"),("leviathansivedem00hobb","1668 年阿姆斯特丹拉丁文版")]),
"pensees":([("Pascal - Pensées - 1670 - Bandeau (FR-631136102 RELp 0061).jpg","1670 年初版（王港版）书页")],[("pensesdeblaise00pascuoft","1896 年依手稿原貌校订本")]),
"locke-government":([("Title page of John Locke, Two Treatises of Government (London, 1690) LCCN2002710224.jpg","1690 年初版扉页，伦敦：丘吉尔")],[("twotreatisesofgo00lock_1","1690 年伦敦初版"),("twotreatisesofgo00lockuoft","1772 年伦敦第七版")]),
"berkeley-principles":([],[("treatiseconcerni00berk","1904 年 Open Court 版，芝加哥")]),
"rousseau-inequality":([("Discours sur l'inégalité.jpg","1755 年初版扉页，阿姆斯特丹：雷伊"),("Fragment du Discours sur l’origine de l’inégalité.jpg","《论不平等》手稿残页（1754 年）")],[("discourssurlori00rous","1755 年阿姆斯特丹初版")]),
"schopenhauer-essays":([("Parerga und Paralipomena (1902).jpg","《附录与补遗》1902 年版")],[("bub_gb_WuUOAAAAIAAJ","1851 年初版，柏林：哈恩")]),
"on-liberty":([("On Liberty (first edition title page via facsimile).jpg","1859 年初版扉页（影印）")],[("onlibertyxero00milluoft","1859 年伦敦初版，帕克")]),
"utilitarianism":([("Utilitarism.jpg","1863 年初版扉页")],[("a592840000milluoft","1863 年伦敦初版")]),
"manifesto":([],[("manifest-der-kommunistischen-partei_202204","1848 年德文初版（扫描）"),("manifestoofcommu00marx_1","1898 年英译本，纽约")]),
"pragmatism":([],[("pragmatismnewnam00jame","1907 年初版，纽约：朗文")]),
"groundwork":([],[("grundlegungzurm00vorlgoog","1785 年初版，里加：哈特克诺赫"),("grundlegungzurm01kantgoog","1786 年第二版")]),
"bge":([],[("bub_gb_YIURAAAAYAAJ","1886 年初版，莱比锡：瑙曼"),("beyondgoodevilpr1909niet","1909 年齐默恩（Zimmern）英译本，爱丁堡")]),
"euclid":([("P. Oxy. I 29.jpg","俄克喜林库斯纸草 29 号：现存最早的《几何原本》残片（约公元 100 年）"),("Euclid's Elements, 1482.jpg","1482 年威尼斯初印本，拉特多尔特印行"),("Byrne 1847 Pythagoras Querformat.jpg","1847 年 Byrne 彩色版：卷一命题 47（勾股定理）")],[("firstsixbooksel00byrn","1847 年 Byrne 彩色版，伦敦：皮克林"),("elementsgeometr00eucl","1570 年 Billingsley 首部英译本，伦敦"),("firstsixbooksel00casegoog","1885 年 Casey 版（本应用英文全文所据），伦敦：朗文"),("06057513.cn","利玛窦、徐光启译《几何原本》卷一")]),
"jiuzhang":([("九章算術細草圖說.jpg","李潢《九章算术细草图说》书页")],[("06057481.cn","《九章算术》卷一至卷三"),("02094024.cn","李潢《九章算术细草图说》（一）")]),
"archimedes":([("Archimedes Palimpsest.jpg","阿基米德重写本：《方法》唯一传世的抄本，10 世纪抄写，后被刮去改写成祈祷书"),("Archimedes - Opere, 1544 - 1291605 pagina 55.jpeg","1544 年巴塞尔初印本《阿基米德全集》书页")],[("geometricalsolut00arch","1909 年英译本，芝加哥：Open Court（本应用全文所据）"),("methodofarchimed00arch","1912 年 Heath 英译《方法》，剑桥大学出版社"),("worksofarchimede00arch","1897 年 Heath《阿基米德全集》英译，剑桥")]),
"zhoubi":([("Chinese pythagoras.jpg","《周髀算经》中的勾股圆方图（弦图）"),("Zhao Shuang's diagram of the Gougu Theorem from the Han era Zhoubi Suanjing.png","赵爽弦图的现代重绘")],[("06076246.cn","《周髀算经》卷上"),("02093859.cn","《周髀算经》附《周髀算经音义》")]),
"geometrie":([("Descartes (1637) La Geometrie Livre 1.png","1637 年初版《几何学》卷一首页"),("DescartesLaGeometriePg3LaMult.jpg","1637 年初版：用作图做乘法（图 1）"),("DescartesLaGeometriePg3SqRt.jpg","1637 年初版：用作图开平方（图 2）")],[("discoursdelamet00desca","1637 年莱顿初版《谈谈方法》，《几何学》为其附录"),("lagomtrie00descuoft","1886 年巴黎 Hermann 版《几何学》")]),
"zarathustra":([],[("alsosprachzarat00nietgoog","1895 年版，莱比锡：瑙曼"),("alsosprachzarath00niet_0","1908 年岛屿出版社版")]),
}
out={}
for b,(cms,ias) in S.items():
    pool={x['title'][5:]:x for x in c[b]['commons']}
    imgs=[]
    for f,cap in cms:
        m=next((v for k,v in pool.items() if k.startswith(f)),None)
        if not m: print('MISSING CM',b,f); continue
        imgs.append({'file':m['title'][5:],'thumb':m['thumb'],'caption':cap,'license':m['license']})
    iap={x['identifier']:x for x in c[b]['ia']}
    scans=[]
    for i,cap in ias:
        if i not in iap: print('MISSING IA',b,i); continue
        x=iap[i]; t=x.get('title'); t=t if isinstance(t,str) else ' '.join(t)
        p=x.get('publisher'); p=p if isinstance(p,str) else ' '.join(p or [])
        scans.append({'ia':i,'caption':cap,'title':t[:140],'publisher':p[:80]})
    out[b]={'images':imgs,'scans':scans}
json.dump(out,open('/home/claude/moon-myths/Sources/editions.json','w'),ensure_ascii=False,indent=1)
print(sum(len(v['images']) for v in out.values()),'images',sum(len(v['scans']) for v in out.values()),'scans',len(out),'books')
