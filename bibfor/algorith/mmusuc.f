      SUBROUTINE MMUSUC(NOMA  ,DEFICO,RESOCO)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/12/2012   AUTEUR SELLENET N.SELLENET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTION) ANY LATER VERSION.                                   
C                                                                       
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
C                                                                       
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  NOMA
      CHARACTER*24 RESOCO,DEFICO          
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - USURE)
C
C CREATION DES CARTES D'USURE
C      
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  DEFICO : SD DE DEFINITION DU CONTACT
C IN  RESOCO : SD DE RESOLUTION DU CONTACT
C
C CONTENU DE LA CARTE
C 1  PROFONDEUR D'USURE
C
C
C
C
      INTEGER      IFM,NIV
      INTEGER      CFDISI,MMINFI 
      INTEGER      NBMAE,NPTM
      CHARACTER*19 USUMOI,USUPLU,USUFIX,USUINI
      INTEGER      JNCMPM,JNCMPP,JNCMPI,JNCMPX
      INTEGER      JVALVM,JVALVP,JVALVI,JVALVX
      CHARACTER*24 NOSDCO
      INTEGER      JNOSDC      
      INTEGER      ICMP,IMAE,IPTM,ITPC
      INTEGER      JDECME,POSMAE
      CHARACTER*2  CH2
      CHARACTER*8  K8BID
      CHARACTER*19 LIGRCF
      INTEGER      NCMPU
      PARAMETER    (NCMPU=1)
      LOGICAL      MMINFL,CFDISL,LUSURE,LVERI
      INTEGER      IZONE,NZOCO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV) 
C
C --- USURE ?      
C      
      LUSURE = CFDISL(DEFICO,'EXIS_USURE')
C
      IF (.NOT. LUSURE) THEN
        GOTO 999
      END IF
C
C --- INITIALISATIONS
C
      NZOCO  = CFDISI(DEFICO,'NZOCO')
C
C --- NBRE COMPOSANTES CARTE USURE
C      
      IF (NCMPU.NE.1) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- AFFICHAGE
C      
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> CREATION DE LA CARTE DES'//
     &        ' PROFILS USURE' 
      ENDIF 
C      
C --- LIGREL DES ELEMENTS TARDIFS DE CONTACT/FROTTEMENT    
C
      NOSDCO = RESOCO(1:14)//'.NOSDCO'
      CALL JEVEUO(NOSDCO,'L',JNOSDC)
      LIGRCF = ZK24(JNOSDC+2-1)(1:19)    
C      
C --- NOM DES CARTES D'USURE      
C
      USUMOI = RESOCO(1:14)//'.USUM'
      USUPLU = RESOCO(1:14)//'.USUP'
      USUFIX = RESOCO(1:14)//'.USUF'
      USUINI = RESOCO(1:14)//'.USUI' 
C
C --- CREATION ET INITIALISATION DES CARTES D'USURE :
C      
      CALL ALCART('V',USUMOI,NOMA,'NEUT_R')
      CALL ALCART('V',USUPLU,NOMA,'NEUT_R')
      CALL ALCART('V',USUINI,NOMA,'NEUT_R')
      CALL ALCART('V',USUFIX,NOMA,'NEUT_R')
C
C --- ACCES CARTES
C
      CALL JEVEUO(USUMOI(1:19)//'.NCMP','E',JNCMPM)
      CALL JEVEUO(USUMOI(1:19)//'.VALV','E',JVALVM)
      CALL JEVEUO(USUPLU(1:19)//'.NCMP','E',JNCMPP)
      CALL JEVEUO(USUPLU(1:19)//'.VALV','E',JVALVP)
      CALL JEVEUO(USUINI(1:19)//'.NCMP','E',JNCMPI)
      CALL JEVEUO(USUINI(1:19)//'.VALV','E',JVALVI)
      CALL JEVEUO(USUFIX(1:19)//'.NCMP','E',JNCMPX)
      CALL JEVEUO(USUFIX(1:19)//'.VALV','E',JVALVX)
C
C --- COMPOSANTES
C
      DO 101 ICMP = 1,NCMPU       
        CALL CODENT(ICMP,'G',CH2)
        ZK8(JNCMPM-1+ICMP) = 'X'//CH2
        ZK8(JNCMPP-1+ICMP) = 'X'//CH2
        ZK8(JNCMPI-1+ICMP) = 'X'//CH2
        ZK8(JNCMPX-1+ICMP) = 'X'//CH2  
  101 CONTINUE
C
C --- BOUCLE SUR LES ZONES
C
      ITPC   = 1
      DO 10 IZONE = 1,NZOCO
        NBMAE  = MMINFI(DEFICO,'NBMAE' ,IZONE )
        JDECME = MMINFI(DEFICO,'JDECME',IZONE )      
C 
C ----- MODE VERIF: ON SAUTE LES POINTS
C  
        LVERI  = MMINFL(DEFICO,'VERIF' ,IZONE )
        IF (LVERI) THEN
          GOTO 25
        ENDIF      
      
        DO 20 IMAE = 1,NBMAE       
C
C ------- POSITION DE LA MAILLE ESCLAVE
C
          POSMAE = JDECME + IMAE
C
C ------- NOMBRE DE POINTS SUR LA MAILLE ESCLAVE
C            
          CALL MMINFM(POSMAE,DEFICO,'NPTM',NPTM  )       
C
C ------- BOUCLE SUR LES POINTS
C      
          DO 30 IPTM = 1,NPTM
            ZR(JVALVM-1+1) = 0.D0         
            CALL NOCART(USUMOI,-3         ,K8BID ,'NUM',1,
     &                  K8BID ,-(ITPC),LIGRCF,NCMPU)
            ZR(JVALVP-1+1) = 0.D0
            CALL NOCART(USUPLU,-3         ,K8BID ,'NUM',1,
     &                  K8BID ,-(ITPC),LIGRCF,NCMPU)
            ZR(JVALVI-1+1) = 0.D0
            CALL NOCART(USUINI,-3         ,K8BID ,'NUM',1,
     &                  K8BID ,-(ITPC),LIGRCF,NCMPU)
            ZR(JVALVX-1+1) = 0.D0
            CALL NOCART(USUFIX,-3         ,K8BID ,'NUM',1,
     &                  K8BID ,-(ITPC),LIGRCF,NCMPU)
C
C --------- LIAISON DE CONTACT SUIVANTE
C
            ITPC   = ITPC + 1 
  30      CONTINUE
  20    CONTINUE
  25    CONTINUE
  10  CONTINUE   
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ... USURE MOINS'
        CALL NMDEBG('VECT',USUMOI,6)
        WRITE (IFM,*) '<CONTACT> ... USURE PLUS'
        CALL NMDEBG('VECT',USUPLU,6)      
        WRITE (IFM,*) '<CONTACT> ... USURE FIXE'
        CALL NMDEBG('VECT',USUFIX,6)
      ENDIF  
C
  999 CONTINUE      
C
      CALL JEDEMA()
      END
