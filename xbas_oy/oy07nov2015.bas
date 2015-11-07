 10 str a[255]
 20 m_init()
 30 m_alloc(1,2000): m_alloc(2,2000): m_alloc(3,2000)
 40 m_assign(1,1): m_assign(2,2): m_assign(3,3)
 100 a="o5v10q7@19 d4d8>a8<c4c4 c4>b8<c8d8c8>b4 a4<d4>a8b8<c8>b8 <d4c8d8>b2"
 110 write_trk(1)
 120 a="o4v10q7@19 l4refgagfedc>bagabc"
 130 write_trk(3)
 1000 m_play()
 1010 end
 2000 func write_trk(i)
 2010	m_trk(i,a)
 2020 endfunc

