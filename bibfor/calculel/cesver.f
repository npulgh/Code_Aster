      SUBROUTINE CESVER(CESZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE PELLET J.PELLET
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*(*) CESZ
C ---------------------------------------------------------------------
C BUT: FAIRE DES VERIFICATIONS SUR UN CHAM_ELEM_S
C      (=> IMPRIMER SUR LE FICHIER .MESS DES INFORMATIONS)
C ---------------------------------------------------------------------
C     ARGUMENTS:
C CESZ   IN/JXIN  K19 : SD CHAM_ELEM_S A VERIFIER
C
C REMARQUES :
C  * POUR L'INSTANT ON FAIT LES VERIFICATIONS SUIVANTES :
C     * SI CES / ELNO  OU CES / ELGA  :
C         SI L'ECART DES VALEURS D'UNE MAILLE (SUR SES POINTS)
C         EST > 10% DU MAX DU CHAMP
C         => MESSAGE POUR DIRE QUE LA DISCRETISATION EST TROP GROSSIERE
C     * SINON : RIEN !
C  * ON NE TRAITE QUE LES CHAMPS REELS OU COMPLEXES
C  * POUR LES CHAMPS COMPLEXES, ON NE REGARDE QUE LA PARTIE REELLE
C  * POUR LES CHAMPS A SOUS-POINTS, ON NE REGARDE QUE LE SOUS-POINT 1
C
C-----------------------------------------------------------------------

C     ------------------------------------------------------------------
      INTEGER JCESK,JCESD,JCESV,JCESL,JCESC,IAD
      INTEGER NBMA,IBID,IMA,NCMP,IPT,ISP,NBPT,ICMP,IMA1
      CHARACTER*24 VALK(3)
      CHARACTER*8 MA,NOMGD,NOMMA,TYPCES
      CHARACTER*3 TSCA
      CHARACTER*19 CES
      REAL*8 RMI1,RMA1,RMI2,RMA2,RDISP,RDISPX,R1,RMAX,VALR(3)
      LOGICAL LEXIMA
C     ------------------------------------------------------------------
      CALL JEMARQ()

      CES = CESZ

      CALL JEVEUO(CES//'.CESK','L',JCESK)
      CALL JEVEUO(CES//'.CESD','L',JCESD)
      CALL JEVEUO(CES//'.CESC','L',JCESC)
      CALL JEVEUO(CES//'.CESV','L',JCESV)
      CALL JEVEUO(CES//'.CESL','L',JCESL)

      MA = ZK8(JCESK-1+1)
      NOMGD = ZK8(JCESK-1+2)
      TYPCES = ZK8(JCESK-1+3)
      NBMA = ZI(JCESD-1+1)
      NCMP = ZI(JCESD-1+2)


C     -- ON NE TRAITE QUE LES CHAMPS ELNO OU ELGA :
      IF (TYPCES.EQ.'ELNO'.OR.TYPCES.EQ.'ELGA') THEN
      ELSE
        GOTO 9999
      ENDIF


C     -- ON NE TRAITE QUE LES CHAMPS R OU C :
C        POUR LES CHAMPS COMPLEXES, ON NE S'INTERESSE QU'A LA
C        PARTIE REELLE.
      CALL DISMOI('F','TYPE_SCA',NOMGD,'GRANDEUR',IBID,TSCA,IBID)
      IF (TSCA.EQ.'R'.OR.TSCA.EQ.'C') THEN
      ELSE
        GOTO 9999
      ENDIF



C     1- PARCOURS DES VALEURS DU CHAMP :
C     ----------------------------------
      DO 80,ICMP = 1,NCMP
        RMI2=1.D200
        RMA2=-1.D200
        RDISPX=0.D0
        DO 70,IMA = 1,NBMA
          NBPT = ZI(JCESD-1+5+4* (IMA-1)+1)
          LEXIMA=.FALSE.
C         -- ON NE REGARDE QUE LE 1ER SOUS-POINT :
          DO 50,ISP = 1,1
            RMI1=1.D200
            RMA1=-1.D200
            DO 60,IPT = 1,NBPT
              CALL CESEXI('C',JCESD,JCESL,IMA,IPT,ISP,ICMP,IAD)
              IF (IAD.LE.0) GO TO 60
              LEXIMA=.TRUE.

              IF (TSCA.EQ.'R') THEN
                R1=ZR(JCESV-1+IAD)
              ELSEIF (TSCA.EQ.'C') THEN
                R1=DBLE(ZC(JCESV-1+IAD))
              ENDIF
              RMI1=MIN(RMI1,R1)
              RMA1=MAX(RMA1,R1)
              RMI2=MIN(RMI2,R1)
              RMA2=MAX(RMA2,R1)
 60         CONTINUE
            IF (LEXIMA) THEN
              RDISP=RMA1-RMI1
            ELSE
              RDISP=0.D0
            ENDIF
            IF (RDISP.GT.RDISPX) THEN
              RDISPX=RDISP
              IMA1=IMA
            ENDIF
 50       CONTINUE
 70     CONTINUE

      RMAX=MAX(ABS(RMI2),ABS(RMA2))
      IF (RDISPX.GT.0.1D0*RMAX) THEN
        VALR(1)=RDISPX
        VALR(2)=RMAX
        VALR(3)=100.D0*RDISPX/RMAX
        CALL JENUNO(JEXNUM(MA//'.NOMMAI',IMA1),NOMMA)
        VALK(1)=NOMMA
        VALK(2)=ZK8(JCESC-1+ICMP)
        VALK(3)=NOMGD
        CALL U2MESG('A','CALCULEL_26',3,VALK,0,0,3,VALR)
      ENDIF

 80   CONTINUE


9999  CONTINUE
      CALL JEDEMA()
      END
