import { createClient, isSupabaseConfigured } from "@/lib/supabase/server"
import { Navigation } from "@/components/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import Link from "next/link"
import { Calendar, MapPin, Users, Trophy, Star, TrendingUp, Clock, Plus } from "lucide-react"

export default async function Home() {
  if (!isSupabaseConfigured) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <h1 className="text-2xl font-bold mb-4">Connect Supabase to get started</h1>
      </div>
    )
  }

  const supabase = createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Get user profile if logged in
  let profile = null
  if (user) {
    const { data } = await supabase.from("profiles").select("*").eq("id", user.id).single()
    profile = data
  }

  // Get recent peladas
  const { data: peladas } = await supabase
    .from("peladas")
    .select(`
      *,
      creator:profiles!peladas_creator_id_fkey(name, avatar_url),
      participants:pelada_participants(count)
    `)
    .eq("status", "open")
    .gte("date_time", new Date().toISOString())
    .order("date_time", { ascending: true })
    .limit(6)

  // Get top players
  const { data: topPlayers } = await supabase
    .from("profiles")
    .select("*")
    .order("rating", { ascending: false })
    .limit(5)

  return (
    <div className="min-h-screen bg-background">
      <Navigation user={user ? { ...user, ...profile } : null} />

      <main className="container mx-auto px-4 py-8">
        {/* Hero Section */}
        <section className="text-center py-12 md:py-20">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-4xl md:text-6xl font-heading font-bold mb-6 gradient-green bg-clip-text text-transparent">
              Sua rede social do futebol de várzea
            </h1>
            <p className="text-xl md:text-2xl text-muted-foreground mb-8 max-w-2xl mx-auto">
              Organize peladas, forme times balanceados, acompanhe suas estatísticas e conecte-se com outros jogadores
            </p>

            {user ? (
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" className="gradient-green text-white" asChild>
                  <Link href="/peladas/create">
                    <Plus className="mr-2 h-5 w-5" />
                    Criar Nova Pelada
                  </Link>
                </Button>
                <Button size="lg" variant="outline" asChild>
                  <Link href="/peladas">
                    <Calendar className="mr-2 h-5 w-5" />
                    Ver Peladas
                  </Link>
                </Button>
              </div>
            ) : (
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" className="gradient-green text-white" asChild>
                  <Link href="/auth/sign-up">Começar Agora</Link>
                </Button>
                <Button size="lg" variant="outline" asChild>
                  <Link href="/peladas">Ver Peladas</Link>
                </Button>
              </div>
            )}
          </div>
        </section>

        {/* Features Section */}
        <section className="py-16">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-heading font-bold mb-4">
              Tudo que você precisa para suas peladas
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Uma plataforma completa para organizar e acompanhar seus jogos de futebol
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <Card className="gradient-card border-0 shadow-lg">
              <CardHeader>
                <div className="h-12 w-12 rounded-lg gradient-green flex items-center justify-center mb-4">
                  <Calendar className="h-6 w-6 text-white" />
                </div>
                <CardTitle>Organize Peladas</CardTitle>
                <CardDescription>
                  Crie peladas com data, local, regras e gerencie participantes facilmente
                </CardDescription>
              </CardHeader>
            </Card>

            <Card className="gradient-card border-0 shadow-lg">
              <CardHeader>
                <div className="h-12 w-12 rounded-lg gradient-green flex items-center justify-center mb-4">
                  <Users className="h-6 w-6 text-white" />
                </div>
                <CardTitle>Times Balanceados</CardTitle>
                <CardDescription>
                  Algoritmo inteligente que forma times equilibrados baseado nas habilidades
                </CardDescription>
              </CardHeader>
            </Card>

            <Card className="gradient-card border-0 shadow-lg">
              <CardHeader>
                <div className="h-12 w-12 rounded-lg gradient-green flex items-center justify-center mb-4">
                  <Trophy className="h-6 w-6 text-white" />
                </div>
                <CardTitle>Estatísticas</CardTitle>
                <CardDescription>Acompanhe gols, assistências, avaliações e conquiste troféus</CardDescription>
              </CardHeader>
            </Card>

            <Card className="gradient-card border-0 shadow-lg">
              <CardHeader>
                <div className="h-12 w-12 rounded-lg gradient-green flex items-center justify-center mb-4">
                  <Star className="h-6 w-6 text-white" />
                </div>
                <CardTitle>Sistema de Avaliação</CardTitle>
                <CardDescription>Avalie outros jogadores e construa sua reputação na comunidade</CardDescription>
              </CardHeader>
            </Card>

            <Card className="gradient-card border-0 shadow-lg">
              <CardHeader>
                <div className="h-12 w-12 rounded-lg gradient-green flex items-center justify-center mb-4">
                  <TrendingUp className="h-6 w-6 text-white" />
                </div>
                <CardTitle>Feed Social</CardTitle>
                <CardDescription>Compartilhe fotos, vídeos e melhores momentos das suas peladas</CardDescription>
              </CardHeader>
            </Card>

            <Card className="gradient-card border-0 shadow-lg">
              <CardHeader>
                <div className="h-12 w-12 rounded-lg gradient-green flex items-center justify-center mb-4">
                  <MapPin className="h-6 w-6 text-white" />
                </div>
                <CardTitle>Localização</CardTitle>
                <CardDescription>Encontre peladas próximas a você e descubra novos campos</CardDescription>
              </CardHeader>
            </Card>
          </div>
        </section>

        {/* Recent Peladas */}
        {peladas && peladas.length > 0 && (
          <section className="py-16">
            <div className="flex items-center justify-between mb-8">
              <div>
                <h2 className="text-3xl font-heading font-bold mb-2">Próximas Peladas</h2>
                <p className="text-muted-foreground">Participe das peladas que estão rolando</p>
              </div>
              <Button variant="outline" asChild>
                <Link href="/peladas">Ver Todas</Link>
              </Button>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {peladas.map((pelada) => (
                <Card key={pelada.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <Badge variant="secondary">{pelada.status === "open" ? "Aberta" : "Fechada"}</Badge>
                      <div className="flex items-center text-sm text-muted-foreground">
                        <Users className="h-4 w-4 mr-1" />
                        {pelada.participants?.[0]?.count || 0}/{pelada.max_players}
                      </div>
                    </div>
                    <CardTitle className="line-clamp-2">{pelada.title}</CardTitle>
                    <CardDescription className="line-clamp-2">{pelada.description}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2 text-sm">
                      <div className="flex items-center text-muted-foreground">
                        <Clock className="h-4 w-4 mr-2" />
                        {new Date(pelada.date_time).toLocaleDateString("pt-BR", {
                          day: "2-digit",
                          month: "2-digit",
                          hour: "2-digit",
                          minute: "2-digit",
                        })}
                      </div>
                      <div className="flex items-center text-muted-foreground">
                        <MapPin className="h-4 w-4 mr-2" />
                        {pelada.location}
                      </div>
                      <div className="flex items-center justify-between pt-2">
                        <div className="flex items-center">
                          <Avatar className="h-6 w-6 mr-2">
                            <AvatarImage src={pelada.creator?.avatar_url || ""} />
                            <AvatarFallback className="text-xs">{pelada.creator?.name?.charAt(0)}</AvatarFallback>
                          </Avatar>
                          <span className="text-xs text-muted-foreground">{pelada.creator?.name}</span>
                        </div>
                        <Button size="sm" variant="outline" asChild>
                          <Link href={`/peladas/${pelada.id}`}>Ver Detalhes</Link>
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </section>
        )}

        {/* Top Players */}
        {topPlayers && topPlayers.length > 0 && (
          <section className="py-16">
            <div className="flex items-center justify-between mb-8">
              <div>
                <h2 className="text-3xl font-heading font-bold mb-2">Melhores Jogadores</h2>
                <p className="text-muted-foreground">Os craques da comunidade</p>
              </div>
              <Button variant="outline" asChild>
                <Link href="/rankings">Ver Ranking</Link>
              </Button>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-5 gap-4">
              {topPlayers.map((player, index) => (
                <Card key={player.id} className="text-center hover:shadow-lg transition-shadow">
                  <CardContent className="pt-6">
                    <div className="relative mb-4">
                      <Avatar className="h-16 w-16 mx-auto">
                        <AvatarImage src={player.avatar_url || ""} />
                        <AvatarFallback className="gradient-green text-white text-lg">
                          {player.name?.charAt(0)}
                        </AvatarFallback>
                      </Avatar>
                      {index < 3 && (
                        <div className="absolute -top-2 -right-2 h-6 w-6 rounded-full bg-yellow-500 flex items-center justify-center">
                          <span className="text-xs font-bold text-white">{index + 1}</span>
                        </div>
                      )}
                    </div>
                    <h3 className="font-semibold mb-1">{player.name}</h3>
                    <div className="flex items-center justify-center mb-2">
                      <Star className="h-4 w-4 text-yellow-500 mr-1" />
                      <span className="text-sm font-medium">{player.rating?.toFixed(1) || "0.0"}</span>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      {player.games_played} jogos • {player.goals} gols
                    </p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </section>
        )}

        {/* CTA Section */}
        {!user && (
          <section className="py-16 text-center">
            <Card className="max-w-2xl mx-auto gradient-card border-0 shadow-xl">
              <CardContent className="pt-8">
                <h2 className="text-3xl font-heading font-bold mb-4">Pronto para começar?</h2>
                <p className="text-lg text-muted-foreground mb-6">
                  Junte-se à maior comunidade de futebol de várzea do Brasil
                </p>
                <Button size="lg" className="gradient-green text-white" asChild>
                  <Link href="/auth/sign-up">Criar Conta Grátis</Link>
                </Button>
              </CardContent>
            </Card>
          </section>
        )}
      </main>
    </div>
  )
}
