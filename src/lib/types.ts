export type Participant = {
  name: string;
  surname: string;
}

export type Opinion = {
  stars: number;
  text: string;
}

export type Event = {
  description: string;
  location: { lat: number; lon: number; }
  duration: number;
  requirements: string;
}

export type Organizer = {
  name: string;
}

export type Coordinator = {
  name: string;
  surname: string;
}
