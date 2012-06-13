      SUBROUTINE CFCPEM(RESOCO,NBLIAI)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*24 RESOCO
      INTEGER      NBLIAI
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (RESOLUTION - PENALISATION)
C
C CALCUL DE LA MATRICE DE CONTACT PENALISEE ELEMENTAIRE [E_N*AT]
C
C ----------------------------------------------------------------------
C 
C
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C IN  NBLIAI : NOMBRE DE LIAISONS DE CONTACT
C
C
C
C
      INTEGER      NDLMAX
      PARAMETER   (NDLMAX = 30)
      REAL*8       JEUINI
      REAL*8       COEFPN,XMU,R8PREM
      INTEGER      ILIAI
      CHARACTER*24 APCOEF,APPOIN
      INTEGER      JAPCOE,JAPPTR
      CHARACTER*24 TACFIN
      INTEGER      JTACF
      CHARACTER*24 JEUX
      INTEGER      JJEUX
      CHARACTER*24 ENAT
      INTEGER      JENAT
      INTEGER      CFMMVD,ZTACF
      INTEGER      NBDDL,JDECAL
C 
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C
      APPOIN = RESOCO(1:14)//'.APPOIN'
      APCOEF = RESOCO(1:14)//'.APCOEF'
      JEUX   = RESOCO(1:14)//'.JEUX'
      TACFIN = RESOCO(1:14)//'.TACFIN'
      ENAT   = RESOCO(1:14)//'.ENAT'
      CALL JEVEUO(APPOIN,'L',JAPPTR)
      CALL JEVEUO(APCOEF,'L',JAPCOE)
      CALL JEVEUO(JEUX  ,'L',JJEUX )
      CALL JEVEUO(TACFIN,'L',JTACF )
      ZTACF  = CFMMVD('ZTACF')
C
C --- CALCUL DE LA MATRICE DE CONTACT PENALISEE
C
      DO 210 ILIAI = 1, NBLIAI
        JDECAL = ZI(JAPPTR+ILIAI-1)
        NBDDL  = ZI(JAPPTR+ILIAI) - ZI(JAPPTR+ILIAI-1)
        JEUINI = ZR(JJEUX+3*(ILIAI-1)+1-1)
        COEFPN = ZR(JTACF+ZTACF*(ILIAI-1)+1)
        CALL JEVEUO(JEXNUM(ENAT,ILIAI),'E',JENAT )
        CALL R8INIR(NDLMAX,0.D0,ZR(JENAT),1)
        IF (JEUINI.LT.R8PREM()) THEN
          XMU    = SQRT(COEFPN)
          CALL DAXPY(NBDDL,XMU,ZR(JAPCOE+JDECAL),1,ZR(JENAT),1)
        ENDIF
        CALL JELIBE(JEXNUM(ENAT,ILIAI))
 210  CONTINUE
C
      CALL JEDEMA()
C
      END
