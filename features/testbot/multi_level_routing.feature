@routing @testbot @mld
Feature: Multi level routing

    Background:
        Given the profile "testbot"
        And the partition extra arguments "--small-component-size 1 --max-cell-sizes 4,16,64"

    Scenario: Testbot - Multi level routing check partition
        Given the node map
            """
            a───b───e───f
            │   │   │   │
            d───c   h───g
                 ╲ ╱
                  ╳
                 ╱ ╲
            i───j   m───n
            │   │   │   │
            l───k───p───o
            """

        And the ways
            | nodes | highway |
            | abcda | primary |
            | efghe | primary |
            | ijkli | primary |
            | nmop  | primary |
            | cm    | primary |
            | hj    | primary |
            | kp    | primary |
            | be    | primary |

        And the data has been extracted
        When I run "osrm-partition --max-cell-sizes 4,16 --small-component-size 1 {processed_file}"
        Then it should exit successfully
        And stdout should not contain "level 1 #cells 1 bit size 1"

    Scenario: Testbot - Multi level routing
        Given the node map
            """
            a───b   e───f
            │   │   │   │
            d───c   h───g
                 ╲ ╱
                  ╳
                 ╱ ╲
            i───j   m───n
            │   │   │   │
            l───k───p───o
            """

        And the nodes
            | node | highway         |
            | i    | traffic_signals |
            | n    | traffic_signals |

        And the ways
            | nodes | highway |
            | abcda | primary |
            | efghe | primary |
            | ijkli | primary |
            | mnopm | primary |
            | cm    | primary |
            | hj    | primary |
            | kp    | primary |
        And the partition extra arguments "--small-component-size 1 --max-cell-sizes 4,16"

        When I route I should get
            | from | to | route                                  | time   |
            | a    | b  | abcda,abcda                            | 20s    |
            | a    | f  | abcda,cm,mnopm,kp,ijkli,hj,efghe,efghe | 229.4s |
            | a    | l  | abcda,cm,mnopm,kp,ijkli,ijkli          | 144.7s |
            | a    | o  | abcda,cm,mnopm,mnopm,mnopm             | 124.7s |
            | f    | l  | efghe,hj,ijkli,ijkli,ijkli             | 124.7s |
            | f    | o  | efghe,hj,ijkli,kp,mnopm,mnopm          | 144.7s |
            | l    | o  | ijkli,kp,mnopm,mnopm                   | 60s    |
            | c    | m  | cm,cm                                  | 44.7s  |

        When I request a travel time matrix I should get
            |   |     a |     f |     l |     o |
            | a |     0 | 229.4 | 144.7 | 124.7 |
            | f | 229.4 |     0 | 124.7 | 144.7 |
            | l | 144.7 | 124.7 |     0 |    60 |
            | o | 124.7 | 144.7 |    60 |     0 |

        When I request a travel time matrix I should get
            |   |     a |     f |     l |     o |
            | a |     0 | 229.4 | 144.7 | 124.7 |

        When I request a travel time matrix I should get
            |   |     a |
            | a |     0 |
            | f | 229.4 |
            | l | 144.7 |
            | o | 124.7 |

        When I request a travel time matrix I should get
            |   |     a |     f |     l |     o |
            | a |     0 | 229.4 | 144.7 | 124.7 |
            | o | 124.7 | 144.7 |    60 |     0 |

        When I request a travel time matrix I should get
            |   |     a |     o |
            | a |     0 | 124.7 |
            | f | 229.4 | 144.7 |
            | l | 144.7 |    60 |
            | o | 124.7 |     0 |


        When I request a travel distance matrix I should get
            |   |       a |       f |       l |         o |
            | a |    0+-2 | 2287+-2 | 1443+-2 |   1243+-2 |
            | f | 2284+-2 |    0+-2 | 1241+-2 |   1443+-2 |
            | l | 1443+-2 | 1244+-2 |    0+-2 |    600+-2 |
            | o | 1243+-2 | 1444+-2 |  600+-2 |      0+-2 |

        When I request a travel distance matrix I should get
            |   | a | f          | l          | o        |
            | a | 0 | 2287.2+-2  | 1443+-2    | 1243+-2  |

        When I request a travel distance matrix I should get
            |   |         a |
            | a |         0 |
            | f | 2284.5+-2 |
            | l |    1443.1 |
            | o |      1243 |

        When I request a travel distance matrix I should get
            |   |    a |      f  |      l  |       o |
            | a |    0 | 2287+-2 | 1443+-2 | 1243+-2 |
            | o | 1243 | 1444+-2 |  600+-2 |    0+-2 |


        When I request a travel distance matrix I should get
            |   |         a |        o  |
            | a |      0+-2 |   1243+-2 |
            | f |   2284+-2 |   1443+-2 |
            | l |   1443+-2 |    600+-2 |
            | o |   1243+-2 |      0+-2 |



    Scenario: Testbot - Multi level routing: horizontal road
        Given the node map
            """
            a───b   e───f
            │   │   │   │
            d───c   h───g
            │           │
            i═══j═══k═══l
            │           │
            m───n   q───r
            │   │   │   │
            p───o───t───s
            """
        And the ways
            | nodes | highway   |
            | abcda | primary   |
            | efghe | primary   |
            | mnopm | primary   |
            | qrstq | primary   |
            | ijkl  | primary   |
            | dim   | primary   |
            | glr   | primary   |
            | ot    | secondary |

        When I route I should get
            | from | to | route                          | time |
            | a    | b  | abcda,abcda                    | 20s  |
            | a    | d  | abcda,abcda                    | 20s  |
            | a    | l  | abcda,dim,ijkl,ijkl            | 100s |
            | a    | p  | abcda,dim,mnopm,mnopm          | 80s  |
            | a    | o  | abcda,dim,mnopm,mnopm          | 100s |
            | a    | t  | abcda,dim,mnopm,ot,ot          | 140s |
            | a    | s  | abcda,dim,ijkl,glr,qrstq,qrstq | 140s |
            | a    | f  | abcda,dim,ijkl,glr,efghe,efghe | 140s |


    Scenario: Testbot - Multi level routing: route over internal cell edge hf
        Given the node map
            """
            a───b
            │   │
            d───c──e───f
                 ╲ │ ╳ │ ╲
                   h───g──i───j
                          │   │
                          l───k
            """
        And the partition extra arguments "--small-component-size 1 --max-cell-sizes 4,16"
        And the ways
            | nodes | maxspeed |
            | abcda |        5 |
            | efghe |        5 |
            | ijkli |        5 |
            | eg    |       10 |
            | ce    |       15 |
            | ch    |       15 |
            | fi    |       15 |
            | gi    |       15 |
            | hf    |      100 |

        When I route I should get
            | from | to | route                      | time   |
            | a    | k  | abcda,ch,hf,fi,ijkli,ijkli | 724.3s |


    Scenario: Testbot - Edge case for matrix plugin with
        Given the node map
            """
            a───b
            │ ╳ │
            d───c
            │   │
            e   f
            │ ╱ │
            h   g───i
            """
        And the partition extra arguments "--small-component-size 1 --max-cell-sizes 5,16,64"

        And the nodes
            | node | highway         |
            | e    | traffic_signals |
            | g    | traffic_signals |

        And the ways
            | nodes | highway | maxspeed |
            | abcda | primary |          |
            | ac    | primary |          |
            | db    | primary |          |
            | deh   | primary |          |
            | cfg   | primary |          |
            | ef    | primary |        1 |
            | eg    | primary |        1 |
            | hf    | primary |        1 |
            | hg    | primary |        1 |
            | gi    | primary |          |

        When I route I should get
            | from | to | route               | time |
            | h    | i  | deh,abcda,cfg,gi,gi | 134s |

        When I request a travel time matrix I should get
            |   |   h |   i |
            | h |   0 | 134 |
            | i | 134 |   0 |
